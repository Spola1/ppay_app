require 'swagger_helper'

describe 'Платежи' do
  include_context 'authorization'

  let!(:rate_snapshot) { create(:rate_snapshot) }

  path '/api/v1/payments/deposits' do

    post 'Создание депозита' do
      tags 'Платежи'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: {}]

      description File.read(Rails.root.join('spec/support/swagger/markdown/v1/payments/deposits.md'))

      let(:payment_type) { Deposit }

      it_behaves_like 'create_payment'
    end
  end
end
