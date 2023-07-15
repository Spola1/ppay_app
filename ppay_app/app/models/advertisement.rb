# frozen_string_literal: true

class Advertisement < ApplicationRecord
  include CardNumberSettable
  include AdvertisementScopes

  has_many :payments
  has_many :deposits
  has_many :withdrawals
  # STI модель - processer < user
  belongs_to :processer

  has_one_attached :payment_link_qr_code

  enum payment_system_type: [:card_number], _prefix: true

  validates_presence_of :direction, :national_currency, :cryptocurrency, :payment_system
  validates :card_number, length: { minimum: 4 }, if: -> { direction == 'Deposit' }

  after_commit :set_payment_link_qr_code, if: -> { payment_link_previously_changed? }

  def sorted_payments
    payments.in_flow_hotlist.sort do |a, b|
      if a.payment_status == b.payment_status
        b.status_changed_at <=> a.status_changed_at
      else
        a.payment_status == 'confirming' ? -1 : 1
      end
    end
  end

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
