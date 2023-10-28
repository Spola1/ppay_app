# frozen_string_literal: true

module Advertisements
  module Filterable
    extend ActiveSupport::Concern

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
    end
  end
end
