# frozen_string_literal: true

class IncomingRequest < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :payment, optional: true
  belongs_to :advertisement, optional: true
  belongs_to :card_mask, class_name: 'Mask', optional: true
  belongs_to :sum_mask, class_name: 'Mask', optional: true
end
