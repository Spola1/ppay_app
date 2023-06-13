# frozen_string_literal: true

shared_examples 'create_external_processing_payment' do |type: :deposit|
  response '201', 'успешное создание' do
    schema '$ref': "#/components/schemas/external_processing_#{type}s_create_response_body_schema"

    include_context 'generate_examples'

    context 'validates schema' do
      run_test!
    end

    it 'creates a payment for the merchant' do |example|
      expect { submit_request(example.metadata) }.to change {
        merchant.reload.public_send(payment_type.to_s.underscore.pluralize).count
      }.from(0).to(1)
    end

    it 'creates an external processing payment' do |example|
      submit_request(example.metadata)

      expect(merchant.public_send(payment_type.to_s.underscore.pluralize).last)
        .to be_external
    end

    context 'deposit', if: type == :deposit do
      it 'sets unique_amount' do |example|
        submit_request(example.metadata)

        expect(merchant.deposits.last).to send("be_unique_amount_#{unique_amount}")
      end

      context 'without payment_link' do
        run_test! do
          case response_body
          in {data: {attributes:}}
            expect(attributes).not_to include(payment_link:)
            expect(attributes).not_to include(payment_link_qr_code_url: be_a(String))
          else
            flunk 'unappropriated response'
          end
        end
      end

      context 'with payment_link' do
        let(:payment_link) { 'https://bank.com/ab/cdefg' }

        run_test! do
          case response_body
          in {data: {attributes: {payment_link: _payment_link,
                                  payment_link_qr_code_url:}}}
            expect(_payment_link).to eq(payment_link)
            expect(payment_link_qr_code_url).to be_a(String)
          else
            flunk 'unappropriated response'
          end
        end
      end
    end
  end

  response '422', 'invalid' do
    include_context 'generate_examples'

    context 'unsupported national currency' do
      let(:national_currency) { 'USD' }

      let(:expected_errors) do
        [
          { 'title' => 'national_currency', 'detail' => national_currency_error, 'code' => 422 }
        ]
      end

      let(:national_currency_error) { "Доступные значения #{NationalCurrency.pluck(:name).join(', ')}" }

      run_test! do |_response|
        expect(response_body['errors']).to eq(expected_errors)
      end
    end

    context 'with check_required' do
      let(:check_required) { true }

      let(:expected_errors) do
        [
          {
            title: 'check_required',
            detail: I18n.t('errors.check_required_with_external_processing'),
            code: 422
          }.stringify_keys
        ]
      end

      run_test! do |_response|
        expect(response_body['errors']).to eq(expected_errors)
      end
    end

    context 'without payment system' do
      let(:payment_system_name) { nil }

      let(:expected_errors) do
        [
          {
            title: 'payment_system',
            detail: I18n.t('activerecord.errors.models.payment.attributes.payment_system.blank'),
            code: 422
          }.stringify_keys
        ]
      end

      run_test! do |_response|
        expect(response_body['errors']).to eq(expected_errors)
      end
    end

    context 'without card number', if: type == :withdrawal do
      let(:card_number) { nil }

      let(:expected_errors) do
        [
          {
            title: 'card_number',
            detail: I18n.t('activerecord.errors.models.payment.attributes.card_number.blank'),
            code: 422
          }.stringify_keys
        ]
      end

      run_test! do |_response|
        expect(response_body['errors']).to eq(expected_errors)
      end
    end

    context 'unsupported unique_amount', if: type == :deposit do
      let(:unique_amount) { :bool }

      let(:expected_errors) do
        [
          { title: 'unique_amount', detail: unique_amount_error, code: 422 }.stringify_keys
        ]
      end

      let(:unique_amount_error) { "Доступные значения #{Payment.unique_amounts.keys.join(', ')}" }

      run_test! do |_response|
        expect(response_body['errors']).to eq(expected_errors)
      end
    end
  end

  response '401', 'unauthorized' do
    let(:merchant_token) { invalid_merchant_token }

    run_test!
  end
end
