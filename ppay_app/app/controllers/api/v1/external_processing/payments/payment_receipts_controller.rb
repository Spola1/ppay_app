# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        class PaymentReceiptsController < Api::V1::PaymentsController
          def create
            raise ActionController::BadRequest unless payment.external?

            @payment_receipt = payment.payment_receipts.new(payment_receipt_params)
            @payment_receipt.save!

            payment.update(arbitration: true) if @payment_receipt.start_arbitration

            render json: serialized_payment_receipt, status: :created
          rescue ActiveSupport::MessageVerifier::InvalidSignature
            raise ActionController::BadRequest
          end

          private

          def serialized_payment_receipt
            PaymentReceipts::Create::PaymentReceiptSerializer.new(@payment_receipt.decorate)
          end

          def payment_receipt_params
            (params[:payment_receipt] ? params.require(:payment_receipt) : params)
              .permit(:image, :comment, :receipt_reason, :start_arbitration)
              .merge(arbitration_source: :merchant_service)
          end
        end
      end
    end
  end
end
