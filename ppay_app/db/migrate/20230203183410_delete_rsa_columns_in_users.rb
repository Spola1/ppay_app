# frozen_string_literal: true

class DeleteRsaColumnsInUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :rsa_private_key
    remove_column :users, :rsa_public_key
  end
end
