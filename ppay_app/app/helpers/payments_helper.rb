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

  def payment_status_partial_exists?(payment, prefix)
    lookup_context.template_exists?(payment.payment_status, payment_prefixes(payment, prefix).join('/'), true)
  end

  def payment_statuses_collection
    Deposit.aasm.states.map do |state|
      [state_translation(state.name), state.name]
    end
  end

  def number_color(number)
    return if number.blank? || number.zero?

    number.positive? ? 'text-green-500' : 'text-red-500'
  end

  def paymet_tr_class(payment)
    'arbitration' if payment.arbitration
  end

  private

  def state_translation(state)
    Payment.human_attribute_name("payment_status.#{ state }")
  end

  def payment_prefixes(payment, prefix)
    [prefix, 'payments', payment.type.underscore.pluralize].compact
  end
end
