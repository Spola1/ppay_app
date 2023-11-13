# frozen_string_literal: true

class Merchant < User
  include TelegramProcessable

  DEFAULT_COMMISSION = 1.0
  DEFAULT_OTHER_COMMISSION = 3.0

  has_many :payments,    foreign_key: :merchant_id
  has_many :deposits,    foreign_key: :merchant_id
  has_many :withdrawals, foreign_key: :merchant_id
  has_many :cards

  has_many :merchant_methods, foreign_key: :merchant_id
  has_many :commissions, through: :merchant_methods
  has_many :payment_systems, -> { distinct }, through: :merchant_methods
  has_many :national_currencies, -> { distinct }, through: :payment_systems
  has_many :form_customizations

  has_many :merchant_processers, foreign_key: :merchant_id
  has_many :whitelisted_processers, through: :merchant_processers, source: :processer

  belongs_to :agent, optional: true

  validates :short_freeze_days, presence: true, if: -> { balance_freeze_type == 'short' }
  validates :long_freeze_percentage, :long_freeze_days, presence: true, if: -> { balance_freeze_type == 'long' }

  validates :short_freeze_days, :long_freeze_days, :long_freeze_percentage,
            numericality: { greater_than: 0 }, allow_nil: true

  validates :short_freeze_days, :long_freeze_days, :long_freeze_percentage,
            presence: true, if: -> { balance_freeze_type == 'mixed' }

  enum unique_amount: {
    none: 0,
    integer: 1,
    decimal: 2
  }, _prefix: true

  enum balance_freeze_type: {
    none: 0,
    short: 1,
    long: 2,
    mixed: 3
  }, _prefix: true

  after_create :fill_in_commissions

  def fill_in_commissions(keywords = nil)
    all_methods = all_possible_methods(keywords)

    return unless all_methods.present?

    merchant_methods.insert_all(all_methods)
    Commission.insert_all(all_possible_commissions)
  end

  def destroy_merchant_methods(keywords = nil)
    all_possible_methods(keywords).each do |method|
      merchant_methods.find_by(method)&.destroy
    end
  end

  def whitelisted_processer?(processer)
    whitelisted_processers.include?(processer)
  end

  private

  def all_possible_methods(keywords)
    PaymentSystem.includes(:national_currency).all.decorate
                 .map { { payment_system_id: _1.id, ps_full_name: _1.full_name } }
                 .product(%w[Deposit Withdrawal].map { { direction: _1 } })
                 .map { _1.inject(:merge) }
                 .select { keywords ? (_1.values.join(' ').downcase.split.intersect? keywords.downcase.split) : true }
                 .map { _1.except(:ps_full_name) }
  end

  def all_possible_commissions
    [{ commission: DEFAULT_COMMISSION }]
      .product(
        merchant_methods.all.map { { merchant_method_id: _1.id } },
        %i[ppay processer working_group agent].map { { commission_type: _1 } }
      )
      .map { _1.inject(:merge) }
      .concat(
        [{ commission: DEFAULT_OTHER_COMMISSION, commission_type: :other }]
          .product(merchant_methods.all.map { { merchant_method_id: _1.id } })
          .map { _1.inject(:merge) }
      )
  end
end
