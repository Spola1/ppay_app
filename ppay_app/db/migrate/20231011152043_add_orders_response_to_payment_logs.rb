class AddOrdersResponseToPaymentLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_logs, :orders_response, :text
  end
end
