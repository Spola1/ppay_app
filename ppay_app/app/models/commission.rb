# frozen_string_literal: true

class Commission < ApplicationRecord
  belongs_to :merchant_method

  validates_presence_of :merchant_method, :commission_type

  validates_uniqueness_of :merchant_method,
                          scope: %i[commission_type],
                          message: 'That kind of commission already exists.'

  enum commission_type: {
    ppay: 0,
    processer: 1,
    working_group: 2,
    agent: 3
  }

  %i[ppay processer working_group agent].each do |commission_type|
    scope commission_type, -> { where(commission_type:) }
  end
end
