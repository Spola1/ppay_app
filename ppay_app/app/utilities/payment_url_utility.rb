# frozen_string_literal: true

class PaymentUrlUtility
  include Rails.application.routes.url_helpers

  attr_reader :payment

  def initialize(payment)
    @payment = payment
  end

  def url
    public_send("payments_#{payment.type.underscore}_url", uuid: payment.uuid)
  end
end
