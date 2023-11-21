# frozen_string_literal: true

module Advertisements
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
      scope :filter_by_status,              ->(status) { where(status:) }
      scope :filter_by_card_number,         ->(card_number) { where('card_number ilike ?', "%#{card_number}%") }
      scope :filter_by_direction,           ->(direction) { where(direction:) }
      scope :filter_by_national_currency,   ->(national_currency) { where(national_currency:) }
      scope :filter_by_payment_system,      ->(payment_system) { where(payment_system:) }
      scope :filter_by_processer,           ->(processer) { where(processer:) }
      scope :filter_by_card_owner_name,     lambda { |card_owner_name|
                                              where('card_owner_name ilike ?', "%#{card_owner_name}%")
                                            }
      scope :filter_by_simbank_card_number, lambda { |simbank_card_number|
                                              where('simbank_card_number ilike ?', "%#{simbank_card_number}%")
                                            }
      scope :filter_by_period,
            ->(period) { where(created_at: PERIOD[period].call) }
      scope :filter_by_created_from, lambda { |created_from|
        where('advertisements.created_at >= ?', created_from.in_time_zone.beginning_of_day)
      }
      scope :filter_by_created_to, lambda { |created_to|
        where('advertisements.created_at <= ?', created_to.in_time_zone.end_of_day)
      }
    end
  end
end
