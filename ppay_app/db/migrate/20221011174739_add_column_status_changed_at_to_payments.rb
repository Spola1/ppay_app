class AddColumnStatusChangedAtToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :status_changed_at, :datetime

    Payment.update_all('status_changed_at = updated_at')
  end
end
