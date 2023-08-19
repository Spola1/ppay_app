# frozen_string_literal: true

module Advertisements
  module Filterable
    extend ActiveSupport::Concern

    included do
      scope :filter_by_status, ->(status) { where(status:) }
      scope :filter_by_card_number, ->(card_number) { where("card_number ilike ?", "%#{card_number}%") }
    end
  end
end
