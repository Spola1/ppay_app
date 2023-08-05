# frozen_string_literal: true

class PaymentDecorator < ApplicationDecorator
  include Rails.application.routes.url_helpers

  delegate_all

  delegate :card_owner_name, :sbp_phone_number, to: :advertisement

  def countdown
    return '00:00:00' if countdown_difference.negative?

    duration = ActiveSupport::Duration.build(countdown_difference).parts

    hours = format('%02d', duration[:hours] || 0)
    minutes = format('%02d', duration[:minutes] || 0)
    seconds = format('%02d', duration[:seconds] || 0)

    "#{hours}:#{minutes}:#{seconds}"
  end

  def countdown_end_time
    if merchant.differ_ftd_and_other_payments? && initial_amount == merchant.ftd_payment_default_summ
      status_changed_at + merchant.ftd_payment_exec_time_in_sec
    else
      status_changed_at + merchant.regular_payment_exec_time_in_sec
    end
  end
  alias expiration_time countdown_end_time

  def human_payment_status
    return unless payment_status

    Payment.human_attribute_name("payment_status.#{payment_status}")
  end

  def human_cancellation_reason
    return unless cancellation_reason

    Payment.human_attribute_name("cancellation_reason.#{cancellation_reason}")
  end

  def human_arbitration_reason
    return unless arbitration_reason

    Payment.human_attribute_name("arbitration_reason.#{arbitration_reason}")
  end

  def fiat_amount_with_currency
    "#{fiat_amount} #{national_currency}"
  end

  def toast_class
    classes = ['toast']
    classes << 'arbitration' if arbitration
    classes << 'deposit' if type == 'Deposit' && !arbitration
    classes.join(' ')
  end

  def flow_class
    classes = ['toast']
    classes << 'flow-arbitration' if arbitration
    classes << 'deposit-transferring' if payment_status == 'transferring' && type == 'Deposit' && !arbitration
    classes << 'deposit-confirming' if payment_status == 'confirming' && type == 'Deposit' && !arbitration
    classes << 'withdrawal-transferring' if payment_status == 'transferring' && type == 'Withdrawal' && !arbitration
    classes << 'withdrawal-confirming' if payment_status == 'confirming' && type == 'Withdrawal' && !arbitration
    classes.join(' ')
  end

  def show_merchant_logo
    return unless form_customization.present? && form_customization.default? && form_customization&.logo

    form_customization.logo
  end

  def logo_image_tag
    return unless form_customization.present? && form_customization.default? && form_customization.logo.present?

    h.content_tag(:div, class: 'show-logo') do
      h.content_tag(:div, class: 'logo_img') do
        h.image_tag(form_customization.logo)
      end
    end
  end

  def background_color_style
    return unless form_customization.present? && form_customization.default? && form_customization&.background_color

    "background-color: #{form_customization.background_color};"
  end

  def button_color_style
    return unless form_customization.present? && form_customization.default? && form_customization&.button_color

    "background-color: #{form_customization.button_color};"
  end

  def human_type
    type == 'Deposit' ? 'ДЕПОЗИТ' : 'ВЫВОД'
  end

  def formatted_status_changed_at
    formatted_date(status_changed_at)
  end

  def card_number
    type == 'Deposit' ? advertisement.card_number : super
  end

  def formatted_card_number
    if ["ЕРИП БНБ", "ЕРИП Альфа", "ЕРИП Белагро"].include?(payment_system)
      card_number
    else
      card_number&.gsub(/(.{4})/, '\1 ')
    end
  end

  def payment_link
    advertisement.payment_link.presence if type == 'Deposit'
  end

  def payment_link_qr_code_url
    return unless advertisement.payment_link.present?

    rails_blob_url(advertisement.payment_link_qr_code) if type == 'Deposit'
  end

  def national_formatted
    formatted_amount(national_currency_amount)
  end

  def initial_formatted
    formatted_amount(initial_amount)
  end

  def cryptocurrency_formatted
    formatted_amount(cryptocurrency_amount)
  end

  def cryptocurrency_four_digits
    cryptocurrency_amount&.round(4)
  end

  def cryptocurrency_commission_amount
    commission_amount&.to_f
  end

  def national_currency_commission_amount
    return unless commission_amount && rate_snapshot

    (cryptocurrency_commission_amount * rate_snapshot.value).to_f
  end

  def form_url
    if type == 'Deposit'
      Rails.application.routes.url_helpers.payments_deposit_path(uuid: uuid, signature: signature)
    elsif type == 'Withdrawal'
      Rails.application.routes.url_helpers.payments_withdrawal_path(uuid: uuid, signature: signature)
    end
  end

  private

  def commission_amount
    return unless transactions.any?

    transactions.commission_transactions.sum(:amount)
  end

  def fiat_amount
    formatted_amount(national_currency_amount)
  end

  def countdown_difference
    countdown_end_time - Time.now
  end
end
