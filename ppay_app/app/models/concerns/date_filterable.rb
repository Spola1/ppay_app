# frozen_string_literal: true

module DateFilterable
  extend ActiveSupport::Concern

  included do
    scope :today, -> { where(created_at: Date.current.beginning_of_day..Date.current.end_of_day) }
    scope :for_day, ->(day) { where(created_at: day.beginning_of_day..day.end_of_day) }
  end
end
