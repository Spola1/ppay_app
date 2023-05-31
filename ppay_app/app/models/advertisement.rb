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

  validates_presence_of :direction, :national_currency, :cryptocurrency, :payment_system
  validates :card_number, length: { minimum: 4 }, if: -> { direction == 'Deposit' }

  before_save :set_payment_link_qr_code, if: -> { payment_link_changed? }

  private

  def set_payment_link_qr_code
    if payment_link.present?
      payment_link_qr_code.attach(
        io: StringIO.new(qr_code_svg),
        filename: "#{SecureRandom.hex}.svg",
        content_type: 'image/svg+xml'
      )
    else
      payment_link_qr_code.purge_later
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
