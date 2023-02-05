# frozen_string_literal: true

# вывод, снятие средств со счета = операция по покупке (buy)
class Withdrawal < Payment
  include StateMachines::Payments::Withdrawal
  include Payments::Transactions::Withdrawal
end
