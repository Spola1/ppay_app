# frozen_string_literal: true

class RemoveBalanceRequestCryptoAddressForAgentAndWorkingGroup < ActiveRecord::Migration[7.0]
  def up
    BalanceRequest.joins(:user)
                  .where(
                    user: { type: %w[Agent WorkingGroup] },
                    requests_type: 'withdraw'
                  )
                  .update_all(crypto_address: 'bep20')
  end
end
