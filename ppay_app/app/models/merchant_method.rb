# frozen_string_literal: true

class MerchantMethod < ApplicationRecord
  include Filterable
  include MerchantMethods::Filterable

  belongs_to :merchant
  belongs_to :payment_system
  delegate :national_currency, to: :payment_system

  has_many :commissions, dependent: :delete_all

  validates_uniqueness_of :merchant,
                          scope: %i[payment_system direction],
                          message: 'That kind of merchant method already exists.'
end
