class CreateCryptoWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :crypto_wallets do |t|
      t.string :address
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
