class CreateNotFoundPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :not_found_payments do |t|
      t.references :advertisement, null: false, foreign_key: true
      t.references :incoming_request, null: false, foreign_key: true
      t.decimal :parsed_amount, precision: 12, scale: 2
      t.string :parsed_card_number

      t.timestamps
    end

    #add_reference :not_found_payments, :payment, foreign_key: true
  end
end
