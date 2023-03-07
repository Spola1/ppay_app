# frozen_string_literal: true

class Commission < ApplicationRecord
  belongs_to :payment_system
  belongs_to :merchant

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
