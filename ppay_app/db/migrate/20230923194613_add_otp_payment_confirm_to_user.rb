class AddOtpPaymentConfirmToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :otp_payment_confirm, :boolean
  end
end
