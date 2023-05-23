# frozen_string_literal: true

module PaymentsHelper
  AVAILABLE_STATUSES_COLLECTION = %i[transferring confirming completed cancelled].freeze
  MANAGEMENT_NAMESPACES = %w[admins processers supports].freeze

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

  def support_payment_statuses_collection
    AVAILABLE_STATUSES_COLLECTION.map { |status| [state_translation(status), status] }
  end

  def can_manage_payment?
    role_namespace.in?(MANAGEMENT_NAMESPACES)
  end

  def cancellation_reasons_collection
    Payment.cancellation_reasons.keys.map do |reason|
      [cancellation_reason_translation(reason), reason]
    end
  end

  def number_color(number)
    return if number.blank? || number.zero?

    number.positive? ? 'text-green-500' : 'text-red-500'
  end

  def payment_filters_params(key)
    params[:payment_filters][key] if params[:payment_filters]
  end

  def payment_systems_collection_for_payment(payment)
    payment.merchant.payment_systems
           .joins(:commissions)
           .where(commissions: { direction: payment.type })
           .distinct
           .pluck(:name)
  end

  def render_qr_code(text)
    qrcode = RQRCode::QRCode.new(text)
    svg = qrcode.as_svg(
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 1.5,
      standalone: true,
      use_path: true
    )

    raw svg
  end

  def payment_status_class(payment)
    case payment.payment_status
    when 'completed'
      'completed-status'
    when 'cancelled'
      'cancelled-status'
    end
  end

  private

  def state_translation(state)
    Payment.human_attribute_name("payment_status.#{state}")
  end

  def cancellation_reason_translation(reason)
    Payment.human_attribute_name("cancellation_reason.#{reason}")
  end

  def payment_prefixes(payment, prefix)
    [prefix, 'payments', payment.type.underscore.pluralize].compact
  end
end
