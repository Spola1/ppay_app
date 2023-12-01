# frozen_string_literal: true

class Advertisement < ApplicationRecord
  include CardNumberSettable
  include AdvertisementScopes
  include Filterable
  include Filterable::Period
  include Advertisements::Filterable
  audited
  acts_as_archival readonly_when_archived: true

  has_many :payments
  has_many :deposits
  has_many :withdrawals
  has_many :advertisement_activities, dependent: :destroy
  has_many :incoming_requests
  # STI модель - processer < user
  belongs_to :processer

  has_one_attached :payment_link_qr_code

  enum payment_system_type: [:card_number], _prefix: true
  enum block_reason: { exceed_daily_usdt_limit: 0 }, _prefix: true

  validates_presence_of :direction, :national_currency, :cryptocurrency, :payment_system
  validates :card_number, length: { minimum: 4 }, if: -> { direction == 'Deposit' }
  validates_uniqueness_of :card_number, scope: %i[direction],
                                        conditions: -> { where(archived_at: nil) },
                                        if: -> { card_number.present? && !archived? }

  after_commit :set_payment_link_qr_code, if: -> { payment_link_previously_changed? }
  after_commit :create_activity_on_activate, if: :saved_change_to_status?
  after_commit :create_activity_on_deactivate, if: :saved_change_to_status?
  before_save :remove_block_reason, if: -> { status && block_reason.present? }

  def exceed_daily_usdt_limit?
    daily_usdt_limit.positive? &&
      payments.completed.last_day.sum(:cryptocurrency_amount) >=
        daily_usdt_limit
  end

  def update_conversion
    return unless payments.present?
    return unless payments.finished.present?

    update(
      conversion: payments_conversion_count,
      completed_payments: payments.completed.count,
      cancelled_payments: payments.cancelled.count
    )
  end

  scope :time_filters,
        lambda { |filtering_params|
          time_filtering_params = filtering_params.extract!(:period, :created_from, :created_to)
          payments_sql = Payment.unscoped.filter_by(time_filtering_params).to_sql
          payments_where_clause = payments_sql.sub('SELECT "payments".* FROM "payments" WHERE', '')
          cancelled_payments_count = "COUNT(case when payments.payment_status = 'cancelled' then 1 else null end)"
          completed_payments_count = "COUNT(case when payments.payment_status = 'completed' then 1 else null end)"
          join_clause = "LEFT OUTER JOIN payments ON payments.advertisement_id = advertisements.id \
                         AND#{payments_where_clause}"
          select_clause = "advertisements.*, \
                         case when (#{cancelled_payments_count} + #{completed_payments_count}) > 0 \
                         then round((100.00*#{completed_payments_count})/(#{cancelled_payments_count} + \
                         #{completed_payments_count}), 2) else 0 end as conversion, \
                         #{cancelled_payments_count} as cancelled_payments, \
                         #{completed_payments_count} as completed_payments"
          select(select_clause)
            .filter_by(filtering_params)
            .joins(join_clause)
            .group('advertisements.id')
        }

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

  def payments_conversion_count
    (payments.completed.count.to_f / payments.finished.count * 100).round(2)
  end

  def remove_block_reason
    self.block_reason = nil
  end
end
