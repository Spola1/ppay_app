# frozen_string_literal: true

class Merchant < User
  has_many :payments,    foreign_key: :merchant_id
  has_many :deposits,    foreign_key: :merchant_id
  has_many :withdrawals, foreign_key: :merchant_id
  has_many :cards

  has_many :merchant_methods, foreign_key: :merchant_id
  has_many :commissions, through: :merchant_methods
  has_many :payment_systems, -> { distinct }, through: :merchant_methods
  has_many :national_currencies, -> { distinct }, through: :payment_systems
  has_many :form_customizations

  belongs_to :agent, optional: true

  before_validation :process_telegram, if: -> { telegram.present? }

  validates :telegram, format: { with: /\A@?\w+\z/ }, allow_blank: true
  validate :telegram_id_presence, if: -> { telegram.present? }

  enum unique_amount: {
    none: 0,
    integer: 1,
    decimal: 2
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

  private

  def process_telegram
    return unless telegram.present?

    telegram.gsub!(/^@/, '')
    notify_service = TelegramNotification::GetUserIdService.new(telegram)
    self.telegram_id = notify_service.get_user_id(telegram)
  end

  def telegram_id_presence
    return unless telegram_changed?

    errors.add(:telegram, :not_found) unless telegram_id.present?
  end

  def all_possible_methods(keywords)
    PaymentSystem.includes(:national_currency).all.decorate
                 .map { { payment_system_id: _1.id, ps_full_name: _1.full_name } }
                 .product(%w[Deposit Withdrawal].map { { direction: _1 } })
                 .map { _1.inject(:merge) }
                 .select { keywords ? (_1.values.join(' ').downcase.split.intersect? keywords.downcase.split) : true }
                 .map { _1.except(:ps_full_name) }
  end

  def all_possible_commissions
    [{ commission: 1 }]
      .product(
        merchant_methods.all.map { { merchant_method_id: _1.id } },
        %i[ppay processer working_group agent].map { { commission_type: _1 } }
      )
      .map { _1.inject(:merge) }
      .concat(
        [{ commission: 3, commission_type: :other }]
          .product(merchant_methods.all.map { { merchant_method_id: _1.id } })
          .map { _1.inject(:merge) }
      )
  end
end
