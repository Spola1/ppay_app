# frozen_string_literal: true

class AddOtherCommissionsForMerchants < ActiveRecord::Migration[7.0]
  def up
    MerchantMethod.find_each do |merchant_method|
      Commission.create(
        {
          merchant_method:,
          commission_type: :other,
          commission: Commission.where.not(commission_type: %i[other agent]).where(merchant_method:).sum(:commission)
        }
      )
    end
  end
end
