# frozen_string_literal: true

module Payments
  module Filterable
    extend ActiveSupport::Concern

    PERIOD = {
      'last_hour' => -> { 1.hour.ago..Time.now },
      'last_3_hours' => -> { 3.hours.ago..Time.now },
      'last_6_hours' => -> { 6.hours.ago..Time.now },
      'last_12_hours' => -> { 12.hours.ago..Time.now },
      'last_day' => -> { 1.day.ago..Time.now },
      'last_3_days' => -> { 3.days.ago..Time.now },
      'yesterday' => -> { 1.day.ago.beginning_of_day..1.day.ago.end_of_day },
      'before_yesterday' => -> { 2.days.ago.beginning_of_day..2.days.ago.end_of_day }
    }.freeze

    included do
      scope :filter_by_created_from, lambda { |created_from|
        where('payments.created_at >= ?', created_from.in_time_zone.beginning_of_day)
      }
      scope :filter_by_created_to, lambda { |created_to|
        where('payments.created_at <= ?', created_to.in_time_zone.end_of_day)
      }
      scope :filter_by_cancellation_reason, ->(cancellation_reason) { where(cancellation_reason:) }
      scope :filter_by_payment_status, ->(payment_status) { where(payment_status:) }
      scope :filter_by_payment_system, ->(payment_system) { where(payment_system:) }
      scope :filter_by_national_currency, ->(national_currency) { where(national_currency:) }
      scope :filter_by_uuid, ->(uuid) { where('uuid::text LIKE ?', "%#{uuid}%") }
      scope :filter_by_external_order_id, ->(external_order_id) { where(external_order_id:) }
      scope :filter_by_national_currency_amount_from,
            ->(national_currency_amount) { where 'national_currency_amount >= ?', national_currency_amount }
      scope :filter_by_national_currency_amount_to,
            ->(national_currency_amount) { where 'national_currency_amount <= ?', national_currency_amount }
      scope :filter_by_cryptocurrency_amount_from,
            ->(cryptocurrency_amount) { where 'cryptocurrency_amount >= ?', cryptocurrency_amount }
      scope :filter_by_cryptocurrency_amount_to,
            ->(cryptocurrency_amount) { where 'cryptocurrency_amount <= ?', cryptocurrency_amount }
      scope :filter_by_merchant,
            ->(merchant_id) { where(merchant_id:) }
      scope :filter_by_period,
            ->(period) { where(created_at: PERIOD[period].call) }
      scope :filter_by_card_number, lambda { |card_number|
            joins(:advertisement).where(advertisements: { card_number: }) }
      scope :filter_by_advertisement_id, lambda { |advertisement_id|
            joins(:advertisement).where(advertisements: { id: advertisement_id }) }
    end
  end
end
