class PaymentDecorator < ApplicationDecorator
  include Rails.application.routes.url_helpers

  delegate_all

  def countdown
    return '00:00:00' if countdown_difference < 0

    duration = ActiveSupport::Duration.build(countdown_difference).parts

    hours = sprintf('%02d', duration[:hours] || 0)
    minutes = sprintf('%02d', duration[:minutes] || 0)
    seconds = sprintf('%02d', duration[:seconds] || 0)

    "#{ hours }:#{ minutes }:#{ seconds }"
  end

  def countdown_end_time
    status_changed_at + 20.minutes
  end

  def human_payment_status
    Payment.human_attribute_name("payment_status.#{payment_status}")
  end

  def fiat_amount_with_currency
    "#{ fiat_amount } #{ national_currency }"
  end

  def human_type
    type == 'Deposit' ? 'Депозит' : 'Вывод'
  end

  def type_icon
    type == 'Deposit' ? 'arrow-up' : 'arrow-down'
  end

  private

  def fiat_amount
    '%.2f' % national_currency_amount
  end

  def countdown_difference
    countdown_end_time - Time.now
  end
end
