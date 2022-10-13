class AddRsaKeysToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :rsa_public_key, :text
    add_column :users, :rsa_private_key, :text

    User.find_each do |user|
      user.send(:generate_rsa_key_pair)
      user.save
    end

    change_column :users, :rsa_public_key, :text, null: false
    change_column :users, :rsa_private_key, :text, null: false
  end
end
