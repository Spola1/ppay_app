class Card < ApplicationRecord
  belongs_to :merchant
  belongs_to :payment
end
