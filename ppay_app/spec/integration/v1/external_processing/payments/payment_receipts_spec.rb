# frozen_string_literal: true

require 'swagger_helper'

describe 'External processing payments receipts' do
  include_context 'authorization'
  let(:check_required) { false }

  path '/api/v1/external_processing/payments/{uuid}/payment_receipts' do
    post 'Создание чека платежа с внешним процессингом' do
      tags 'Платежи - H2H (оплата на стороне магазина)'

      consumes 'multipart/form-data'
      produces 'application/json'
      security [bearerAuth: {}]

      description_erb 'external_processing/payments/payment_receipts.md.erb'

      parameter name: :uuid, in: :path, type: :string, required: true
      parameter name: :payment_receipt, in: :formData, schema: {
        type: :object,
        properties: {
          image: { type: :file },
          comment: { type: :string },
          receipt_reason: { type: :string },
          start_arbitration: { type: :boolean }
        },
        required: %w[image]
      }

      let(:arbitration_reason) { 'duplicate_payment' }
      let(:advertisement) { create :advertisement }
      let(:payment) do
        create :payment, :deposit, :transferring,
               merchant:,
               processing_type: :external,
               arbitration_reason:,
               advertisement:
      end
      let(:uuid) { payment.uuid }

      let(:image) { fixture_file_upload('spec/fixtures/test_files/sample.jpeg', 'image/jpeg') }
      let(:comment) { 'comment' }
      let(:receipt_reason) { 'fraud_attempt' }
      let(:start_arbitration) { true }

      let(:payment_receipt) do
        {
          image:,
          comment:,
          receipt_reason:,
          start_arbitration:
        }
      end

      response '201', 'чек успешно создан' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     type: { type: :string },
                     attributes: {
                       type: :object,
                       properties: {
                         image_url: { type: :string },
                         comment: { type: :string, nullable: true },
                         receipt_reason: { type: :string, enum: PaymentReceipt.receipt_reasons, nullable: true },
                         start_arbitration: { type: :boolean, nullable: true },
                         source: { type: :string, enum: PaymentReceipt.sources, nullable: true }
                       },
                       required: %i[image_url comment receipt_reason start_arbitration source]
                     }
                   },
                   required: %i[id type]
                 }
               }

        context 'validates schema' do
          run_test! do
            expect(response_body[:data][:id]).to eq payment.payment_receipts.first.id.to_s
            expect(response_body[:data][:type]).to eq 'payment_receipt'
            expect(response_body[:data][:attributes][:comment]).to eq comment
            expect(response_body[:data][:attributes][:receipt_reason]).to eq receipt_reason.to_s
            expect(response_body[:data][:attributes][:start_arbitration]).to eq start_arbitration
            expect(response_body[:data][:attributes][:source]).to eq 'merchant_service'
          end
        end

        it 'creates a payment receipt for the payment' do |example|
          expect { submit_request(example.metadata) }.to change {
            payment.payment_receipts.count
          }.from(0).to(1)
        end

        it 'changes the payment status to confirming' do |example|
          expect { submit_request(example.metadata) }.to change {
            payment.reload.payment_status
          }.from('transferring').to('confirming')
        end

        it 'sets payment in an arbitration' do |example|
          expect { submit_request(example.metadata) }.to change {
            payment.reload.arbitration
          }.from(false).to(true)
        end

        it 'changes payment\'s arbitration_reason' do |example|
          expect { submit_request(example.metadata) }.to change {
            payment.reload.arbitration_reason
          }.from(arbitration_reason).to(receipt_reason)
        end

        context 'start_arbitration is false' do
          let(:start_arbitration) { false }

          it 'does not set payment in an arbitration' do |example|
            expect { submit_request(example.metadata) }.not_to change {
              payment.reload.arbitration
            }.from(false)
          end

          it 'does not change payment\'s arbitration_reason' do |example|
            expect { submit_request(example.metadata) }.not_to change {
              payment.reload.arbitration_reason
            }.from(arbitration_reason)
          end
        end
      end

      response '400', 'чек не создан' do
        context 'no image' do
          let(:image) { nil }

          run_test! do
            expect(payment.payment_receipts.count).to eq 0
          end
        end
      end
    end
  end
end
