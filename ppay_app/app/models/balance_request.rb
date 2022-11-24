class BalanceRequest < ApplicationRecord
  belongs_to :user

  after_update :create_transaction

  enum requests_type: {
    deposit: 1,
    withdraw: 2,
  }

  enum status: {
    main: 0,
    waiting: 1,
    completed: 2,
  }


  private

  def create_transaction
    if self.status == "completed"
      if self.requests_type == "deposit"
        tr = Transaction.create(to_balance: self.user.balance,
                            amount: self.amount,
                            transaction_type: :deposit)
        tr.complete!
      else self.requests_type == "withdraw"
        tr = Transaction.create(from_balance: self.user.balance,
                            amount: self.amount,
                            transaction_type: :withdraw)
        tr.complete!
      end
    end
  end
end
