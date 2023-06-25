class AddReferenceMerchantToFormCustomization < ActiveRecord::Migration[7.0]
  def change
    add_reference :form_customizations, :merchant
  end
end
