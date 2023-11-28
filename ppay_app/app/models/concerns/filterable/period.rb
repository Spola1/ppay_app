# frozen_string_literal: true

module Filterable
  module Period
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
      scope :filter_by_period, ->(period) { where(created_at: PERIOD[period].call) }
    end
  end
end
