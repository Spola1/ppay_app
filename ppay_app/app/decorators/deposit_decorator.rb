# frozen_string_literal: true

class DepositDecorator < PaymentDecorator
  include Rails.application.routes.url_helpers

  delegate_all

  def url
    payments_deposits_url(uuid:, signature:)
  end
end
