# frozen_string_literal: true

class Payment < ApplicationRecord
  default_scope { order(created_at: :desc) }

  has_many :transactions

  # в каждый платеж прикрепляем курс на данный момент
  # это обязательно
  belongs_to :rate_snapshot, optional: true
  belongs_to :advertisement, optional: true

  #обязательная связь (с моделью STI - merchant < user)
  belongs_to :merchant, optional: true

  has_one :card

  has_one_attached :image

  has_many :comments, as: :commentable

  after_update_commit -> do
    broadcast_replace_to(
      "payment_#{ self.uuid }",
      partial: "payments/show_turbo_frame",
      locals: { payment: self.decorate, signature: self.signature },
      target: "payment_#{ self.uuid }"
    )
  end

  scope :waiting_for_payment, -> { where(payment_status: 'waiting_for_payment') }
  scope :expired,             -> { where('status_changed_at < ?', 20.minutes.ago) }

  %i[created draft processer_search transferring confirming completed cancelled].each do |status|
    scope status, -> { where(payment_status: status) }
  end

  def signature
    data = { national_currency:, national_currency_amount:, external_order_id: }.to_json

    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), merchant.api_keys.last.token, data)
  end
end
