# frozen_string_literal: true

class RemoveBalanceRequestCryptoAddressForAgentAndWorkingGroup < ActiveRecord::Migration[7.0]
  def up
    agent_and_wg_ids = User.where(type: %w[Agent WorkingGroup]).pluck(:id)

    BalanceRequest.where(user_id: agent_and_wg_ids, requests_type: 'withdraw').update_all(crypto_address: 'bep20')
  end
end
