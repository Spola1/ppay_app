# внесение средств на баланс = операция по продаже (sell)
class Deposit < Payment
  include StateMachines::Payments::Deposit
  include Payments::Transactions::Deposit
end
