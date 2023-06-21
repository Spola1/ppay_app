# frozen_string_literal: true

class Merchant < User
  has_many :payments,    foreign_key: :merchant_id
  has_many :deposits,    foreign_key: :merchant_id
  has_many :withdrawals, foreign_key: :merchant_id
  has_many :cards

  has_many :merchant_methods, foreign_key: :merchant_id
  has_many :commissions, through: :merchant_methods
  has_many :payment_ways, -> { distinct }, through: :merchant_methods
  has_many :payment_systems, -> { distinct }, through: :payment_ways
  has_many :national_currencies, -> { distinct }, through: :payment_ways
  has_one :form_customization

  belongs_to :agent, optional: true

  enum unique_amount: {
    none: 0,
    integer: 1,
    decimal: 2
  }, _prefix: true

  after_create :fill_in_commissions

  def fill_in_commissions
    merchant_methods.insert_all(all_possible_methods)
    Commission.insert_all(all_possible_commissions)
  end

  private

  def all_possible_methods
    PaymentWay.all.map { { payment_way_id: _1.id } }
      .product(%w[Deposit Withdrawal].map { { direction: _1 } })
      .map { _1.inject(:merge) }
  end

  def all_possible_commissions
    [{ commission: 1 }]
      .product(
        merchant_methods.all.map { { merchant_method_id: _1.id } },
        %i[ppay processer working_group agent].map { { commission_type: _1 } }
      )
      .map { _1.inject(:merge) }
  end
end
