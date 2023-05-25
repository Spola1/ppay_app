namespace :balance do
  desc 'Update balances'
  task update: :environment do
    balances = Balance.where(in_national_currency: true)

    balances.each do |balance|
      to_transactions_sum = balance.to_transactions.completed.sum(:national_currency_amount)
      balance.amount += to_transactions_sum

      from_transactions_sum = balance.from_transactions.completed.sum(:national_currency_amount)
      balance.amount -= from_transactions_sum

      balance.save
    end
  end
end