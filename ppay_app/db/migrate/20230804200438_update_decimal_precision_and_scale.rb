class UpdateDecimalPrecisionAndScale < ActiveRecord::Migration[7.0]
  def change
    change_column :balance_requests, :amount, :decimal, precision: 128, scale: 64
    change_column :not_found_payments, :parsed_amount, :decimal, precision: 128, scale: 64
    change_column :payments, :cryptocurrency_amount, :decimal, precision: 128, scale: 64
    change_column :payments, :national_currency_amount, :decimal, precision: 128, scale: 64
    change_column :payments, :initial_amount, :decimal, precision: 128, scale: 64
  end
end
