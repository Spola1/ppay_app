class AddFormCustomizationIdToPayments < ActiveRecord::Migration[7.0]
  def change
    add_reference :payments, :form_customization, foreign_key: true
  end
end
