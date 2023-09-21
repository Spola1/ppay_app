class AddUserAgentToAudits < ActiveRecord::Migration[7.0]
  def change
    add_column :audits, :user_agent, :string
  end
end
