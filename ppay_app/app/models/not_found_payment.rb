# frozen_string_literal: true

class NotFoundPayment < ApplicationRecord
  belongs_to :advertisement
  belongs_to :incoming_request
  has_and_belongs_to_many :payments
end
