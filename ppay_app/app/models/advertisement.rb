# frozen_string_literal: true

class Advertisement < ApplicationRecord
  include CardNumberSettable

  has_many :payments
  has_many :deposits
  has_many :withdrawals
  # STI модель - processer < user
  belongs_to :processer

  has_one_attached :payment_link_qr_code

  enum payment_system_type: [:card_number], _prefix: true

  scope :active,               -> { where(status: true) }
  scope :by_payment_system,    ->(payment_system) { where(payment_system:) }
  scope :by_amount,            ->(amount) { where('max_summ >= :amount AND min_summ <= :amount', amount:) }
  scope :by_processer_balance, ->(amount) { joins(processer: :balance).where('balances.amount >= ?', amount) }
  scope :by_direction,         ->(direction) { where(direction:) }
  scope :with_arbitration_or_confirming_payment, -> {
    where(id: Payment.where('arbitration = ? OR payment_status = ?', true, 'confirming').select(:advertisement_id))
  }

  scope :for_payment,          ->(payment) do
    order = Arel.sql('SUM(CASE WHEN ' \
                       "payments.initial_amount = #{ payment.initial_amount } AND " \
                       "payments.payment_status NOT IN ('completed', 'cancelled')" \
                       'THEN 1 ELSE 0 END) ASC,' \
                     'COUNT(payments.id) ASC,' \
                     'RANDOM()')

    left_joins(:payments)
      .active
      .by_payment_system(payment.payment_system)
      .group('advertisements.id')
      .order(order)
  end

  validates_presence_of :direction, :national_currency, :cryptocurrency, :payment_system
  validates :card_number, length: { minimum: 4 }, if: -> { direction == 'Deposit' }

  after_commit :set_payment_link_qr_code, if: -> { payment_link_previously_changed? }

  private

  def set_payment_link_qr_code
    if payment_link.blank?
      payment_link_qr_code.purge_later
    else
      payment_link_qr_code.attach(
        io: StringIO.new(qr_code_svg),
        filename: "#{SecureRandom.hex}.svg",
        content_type: 'image/svg+xml'
      )
    end
  end

  def qr_code_svg
    qrcode = RQRCode::QRCode.new(payment_link)
    qrcode.as_svg(
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 3,
      standalone: true,
      use_path: true
    )
  end
end
