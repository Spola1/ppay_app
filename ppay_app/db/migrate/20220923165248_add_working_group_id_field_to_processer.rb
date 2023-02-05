# frozen_string_literal: true

class AddWorkingGroupIdFieldToProcesser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :working_group_id, :integer
  end
end
