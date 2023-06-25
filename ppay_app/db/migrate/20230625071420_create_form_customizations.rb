class CreateFormCustomizations < ActiveRecord::Migration[7.0]
  def change
    create_table :form_customizations do |t|
      t.string :button_color
      t.string :background_color

      t.timestamps
    end
  end
end
