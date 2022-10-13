class AddAgentReferenceToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :agent
  end
end
