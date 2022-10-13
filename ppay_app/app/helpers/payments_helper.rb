# frozen_string_literal: true

module PaymentsHelper
  def edit_payment_path(payment)
    public_send("edit_payments_#{payment.type.underscore}_path", uuid: payment.uuid)
  end
end
