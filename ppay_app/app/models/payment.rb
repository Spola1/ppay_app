# frozen_string_literal: true

class Payment < ApplicationRecord
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
      "#{ self.uuid }_show",
      partial: "payments/show_turbo_frame",
      locals: { payment: self.decorate, signature: self.signature },
      target: "#{ self.uuid }_show"
    )
  end

  scope :waiting_for_payment, -> { where(payment_status: 'waiting_for_payment') }
  scope :expired,             -> { where('status_changed_at < ?', 20.minutes.ago) }

  def signature
    data = { national_currency:, national_currency_amount:, external_order_id: }.to_json

    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), merchant.api_keys.last.token, data)
  end
end
