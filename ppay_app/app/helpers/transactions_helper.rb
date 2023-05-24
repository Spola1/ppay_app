# frozen_string_literal: true

module TransactionsHelper
  def transaction_color(transaction, balance)
    return if transaction.cancelled?

    transaction.from_balance == balance ? 'text-red-500' : 'text-green-500'
  end

  def transaction_icon(transaction, balance)
    transaction.from_balance == balance ? 'arrow-down' : 'arrow-up'
  end

  def crypto_address_label
    national_balance? ? t('activerecord.attributes.balance_request.card_number') : 
                        t('activerecord.attributes.balance_request.crypto_address')
  end

  def crypto_address_hint
    national_balance? ? 'Номер карты, на которую вам перевести деньги' : 
                        'Кошелёк, на который вам перевести деньги'
  end

  def national_balance?
    current_user.is_a?(Merchant) && current_user.balance.in_national_currency?
  end
end
