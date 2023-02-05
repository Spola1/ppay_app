# frozen_string_literal: true

class AddShortCommentFieldToBalanceRequestsTable < ActiveRecord::Migration[7.0]
  def change
    add_column :balance_requests, :short_comment, :text
  end
end
