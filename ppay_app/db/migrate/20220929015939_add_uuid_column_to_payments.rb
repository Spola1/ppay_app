class AddUuidColumnToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :uuid, :uuid, default: -> { "gen_random_uuid()" }
    add_column :payments, :external_order_id, :string
  end
end
