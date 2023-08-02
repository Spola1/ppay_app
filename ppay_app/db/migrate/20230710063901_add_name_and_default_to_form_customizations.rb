class AddNameAndDefaultToFormCustomizations < ActiveRecord::Migration[7.0]
  def change
    add_column :form_customizations, :name, :string
    add_column :form_customizations, :default, :boolean, default: false, null: false
  end
end
