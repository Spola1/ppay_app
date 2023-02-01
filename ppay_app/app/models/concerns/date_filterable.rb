module DateFilterable
  extend ActiveSupport::Concern

  included do
    scope :today, -> { where(created_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  end
end
