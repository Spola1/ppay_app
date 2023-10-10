# frozen_string_literal: true

class Advertisement < ApplicationRecord
  include CardNumberSettable
  include AdvertisementScopes
  include Filterable
  include Advertisements::Filterable
  audited
  acts_as_archival readonly_when_archived: true

  has_many :payments
  has_many :deposits
  has_many :withdrawals
  has_many :advertisement_activities, dependent: :destroy
  # STI модель - processer < user
  belongs_to :processer

  has_one_attached :payment_link_qr_code

  enum payment_system_type: [:card_number], _prefix: true

  validates_presence_of :direction, :national_currency, :cryptocurrency, :payment_system
  validates :card_number, length: { minimum: 4 }, if: -> { direction == 'Deposit' }
  validates :card_number, uniqueness: { scope: %i[direction] }, if: -> { card_number.present? }

  after_commit :set_payment_link_qr_code, if: -> { payment_link_previously_changed? }
  after_commit :create_activity_on_activate, if: :saved_change_to_status?
  after_commit :create_activity_on_deactivate, if: :saved_change_to_status?

  private

  def create_activity_on_activate
    advertisement_activities.create if status?
  end

  def create_activity_on_deactivate
    last_activity = advertisement_activities.last
    last_activity.update(deactivated_at: Time.now) if last_activity && !status?
  end

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
