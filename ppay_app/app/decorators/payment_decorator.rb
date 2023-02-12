# frozen_string_literal: true

class PaymentDecorator < ApplicationDecorator
  include Rails.application.routes.url_helpers

  delegate_all

  def countdown
    return '00:00:00' if countdown_difference.negative?

    duration = ActiveSupport::Duration.build(countdown_difference).parts

    hours = format('%02d', duration[:hours] || 0)
    minutes = format('%02d', duration[:minutes] || 0)
    seconds = format('%02d', duration[:seconds] || 0)

    "#{hours}:#{minutes}:#{seconds}"
  end

  def countdown_end_time
    status_changed_at + 20.minutes
  end

  def human_payment_status
    Payment.human_attribute_name("payment_status.#{payment_status}")
  end

  def human_cancellation_reason
    Payment.human_attribute_name("cancellation_reason.#{cancellation_reason}")
  end

  def fiat_amount_with_currency
    "#{fiat_amount} #{national_currency}"
  end

  def human_type
    type == 'Deposit' ? 'Депозит' : 'Вывод'
  end

  def type_icon
    type == 'Deposit' ? 'arrow-up' : 'arrow-down'
  end

  def formatted_status_changed_at
    formatted_date(status_changed_at)
  end

  private

  def fiat_amount
    '%.2f' % national_currency_amount
  end

  def countdown_difference
    countdown_end_time - Time.now
  end
end
