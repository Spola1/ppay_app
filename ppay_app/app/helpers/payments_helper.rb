# frozen_string_literal: true

module PaymentsHelper
  def edit_payment_path(payment)
    public_send("edit_payments_#{payment.type.underscore}_path", uuid: payment.uuid)
  end

  def payment_path(payment)
    public_send("payments_#{payment.type.underscore}_path", uuid: payment.uuid)
  end

  def payment_status_partial(payment, prefix = nil)
    return unless payment_status_partial_exists?(payment, prefix)

    payment_prefixes(payment, prefix).push(payment.payment_status).join('/')
  end

  private

  def payment_status_partial_exists?(payment, prefix)
    lookup_context.template_exists?(payment.payment_status, payment_prefixes(payment, prefix).join('/'), true)
  end

  def payment_prefixes(payment, prefix)
    [prefix, 'payments', payment.type.underscore.pluralize].compact
  end
end
