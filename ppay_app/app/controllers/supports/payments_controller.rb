# frozen_string_literal: true

module Supports
  class PaymentsController < Staff::BaseController
    before_action :find_payment, only: %i[update show]

    def index
      respond_to do |format|
        format.html do
          set_all_payments
        end

        format.xlsx do
          render xlsx: 'payments',
                 locals: { payments: Payment.filter_by(filtering_params).includes(:merchant).decorate }
        end
      end
    end

    def show
      @payment_receipt = @payment.payment_receipts.new

      mark_messages_as_read(@payment.comments)
      mark_messages_as_read(@payment.chats)
    end

    def update
      if params[:fire_event]
        @payment.aasm.fire!(params[:event]) if params[:event].present?
      elsif params[:restore]
        @payment.restore!
      elsif params[:rollback]
        @payment.rollback!
      elsif params[:change_national_currency_amount]
        change_national_currency_amount
      elsif params[:send_update_callback]
        @payment.send_update_callback
      else
        @payment.update(payment_params)
      end

      render :show
    end

    private

    def change_national_currency_amount
      return if @payment.transactions.present?

      @payment.update(national_currency_amount: params[:national_currency_amount])
      @payment.restore!
    end

    def mark_messages_as_read(messages)
      message_ids = messages.map(&:id)
      MessageReadStatus.where(user: current_user, message_id: message_ids).update_all(read: true)
    end

    def set_all_payments
      @pagy, @payments = pagy(Payment.filter_by(filtering_params).includes(:merchant))
      @payments = @payments.decorate

      @arbitration_payments_pagy, @arbitration_payments = pagy(filtered_payments, page_param: :arbitration_page)
      @arbitration_payments = @arbitration_payments.decorate
    end

    def find_payment
      @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
    end

    def payment_params
      required_params.permit(:arbitration, :cancellation_reason, :arbitration_reason)
    end

    def filtering_params
      params[:payment_filters]&.slice(:created_from, :created_to, :cancellation_reason, :payment_status,
                                      :payment_system, :national_currency, :national_currency_amount_from,
                                      :national_currency_amount_to, :cryptocurrency_amount_from,
                                      :cryptocurrency_amount_to, :uuid, :external_order_id, :card_number,
                                      :advertisement_id)
    end

    def filtered_payments
      payments = Payment.arbitration.includes(:merchant, :advertisement)

      if filtering_params.present?
        if filtering_params[:card_number].present?
          payments = payments.joins(:advertisement).where(advertisements: { card_number: filtering_params[:card_number] })
        end

        if filtering_params[:advertisement_id].present?
          payments = payments.joins(:advertisement).where(advertisements: { id: filtering_params[:advertisement_id] })
        end

        payments = payments.filter_by(filtering_params)
      end

      payments
    end
  end
end
