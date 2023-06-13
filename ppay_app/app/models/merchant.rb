# frozen_string_literal: true

class Merchant < User
  has_many :payments,    foreign_key: :merchant_id
  has_many :deposits,    foreign_key: :merchant_id
  has_many :withdrawals, foreign_key: :merchant_id
  has_many :cards
  has_many :commissions, foreign_key: :merchant_id
  has_many :payment_systems, through: :commissions
  has_one :form_customization
  belongs_to :agent, optional: true

  enum unique_amount: {
    none: 0,
    integer: 1,
    decimal: 2
  }, _prefix: true

  after_create :fill_in_commissions

  def fill_in_commissions
    commissions.create(all_possible_commissions)
  end

  private

  def all_possible_commissions
    [{ commission: 1 }]
      .product(
        PaymentSystem.all.map { { payment_system: _1 } },
        NationalCurrency.pluck(:name).map { { national_currency: _1 } },
        %w[Deposit Withdrawal].map { { direction: _1 } },
        %i[ppay processer working_group agent].map { { commission_type: _1 } }
      )
      .map { _1.inject(:merge) }
  end
end
