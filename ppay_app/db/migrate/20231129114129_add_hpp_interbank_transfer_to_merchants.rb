class AddHppInterbankTransferToMerchants < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :hpp_interbank_transfer, :boolean
  end
end
