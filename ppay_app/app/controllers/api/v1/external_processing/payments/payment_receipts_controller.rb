# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        class PaymentReceiptsController < Api::V1::PaymentsController
          def create
            raise ActionController::BadRequest unless payment.external?

            @payment_receipt = payment.payment_receipts.new(prepared_payment_receipt_params)
            @payment_receipt.save!

            payment.check! if payment.transferring?

            render json: serialized_payment_receipt, status: :created
          rescue ActiveSupport::MessageVerifier::InvalidSignature
            raise ActionController::BadRequest
          end

          private

          def prepared_payment_receipt_params
            payment_receipt_params.merge(
              source: :merchant_service,
              user: current_bearer,
              start_arbitration: ActiveModel::Type::Boolean.new.cast(payment_receipt_params[:start_arbitration])
            )
          end

          def serialized_payment_receipt
            PaymentReceipts::Create::PaymentReceiptSerializer.new(@payment_receipt.decorate)
          end

          def payment_receipt_params
            (params[:payment_receipt].present? ? params.require(:payment_receipt) : params)
              .permit(:image, :comment, :receipt_reason, :start_arbitration)
          end
        end
      end
    end
  end
end
