class AddBearerUserToAudits < ActiveRecord::Migration[7.0]
  def change
    add_reference :audits, :bearer_user, null: true, polymorphic: true, index: true
  end
end
