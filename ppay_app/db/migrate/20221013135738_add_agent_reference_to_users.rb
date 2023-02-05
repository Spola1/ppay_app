# frozen_string_literal: true

class AddAgentReferenceToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :agent
  end
end
