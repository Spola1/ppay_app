# frozen_string_literal: true

class PaymentSystem < ApplicationRecord
  has_many :merchant_methods, dependent: :destroy
  has_many :commissions, through: :merchant_methods
  has_many :merchants, through: :merchant_methods
  has_many :rate_snapshots, dependent: :destroy

  belongs_to :payment_system_copy, class_name: 'PaymentSystem', optional: true
  belongs_to :national_currency
  belongs_to :exchange_portal

  def self.all_possible_methods(keywords = nil)
    includes(:national_currency).all.decorate
                                .map { { payment_system_id: _1.id, ps_full_name: _1.full_name } }
                                .product(%w[Deposit Withdrawal].map { { direction: _1 } })
                                .map { _1.inject(:merge) }
                                .select { keywords ? (_1.values.join(' ').downcase.split.intersect? keywords.downcase.split) : true }
                                .map { _1.except(:ps_full_name) }
  end
end
