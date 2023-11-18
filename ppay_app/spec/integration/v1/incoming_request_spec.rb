# frozen_string_literal: true

require 'swagger_helper'

describe 'Incoming requests' do
  include_context 'processer authorization'

  path '/api/v1/simbank/requests' do
    post 'Отправить входящий запрос' do
      tags 'Входящие запросы'

      description_erb 'simbank/requests.md.erb'

      consumes 'application/json'
      security [bearerAuth: {}]

      parameter name: :params, in: :body, schema: { type: :object, properties: {
        app: { type: :string, example: 'SMS Forwarder' },
        api_key: { type: :string, example: 'a61990273e8e029665ab9e3522f87da9a81941f3fee929f9' },
        type: { type: :string, example: 'SMS' },
        id: { type: :string },
        from: { type: :string, example: 'Raiffeisen' },
        to: { type: :string },
        message: { type: :string },
        content: { type: :string, example: 'Schet *8412. Platezh s nomera 79529048819. ' \
                                           'Summa 3000.00 RUB. Balans 94.87 RUB.' },
        res_sn: { type: :string },
        identifier: { type: :object, properties: {
          imei: { type: :string },
          imsi: { type: :string },
          phone: { type: :string, example: '79232005555' }
        } },
        imsi: { type: :string },
        imei: { type: :string },
        telegram_phone: { type: :string },
        com: { type: :string },
        simno: { type: :string },
        softwareid: { type: :string },
        custmemo: { type: :string },
        sendstat: { type: :string },
        user_agent: { type: :string }
      } }

      let(:params) do
        {
          type: 'SMS',
          api_key: processer.token,
          from: 'Raiffeisen',
          content: 'Schet *8412. Platezh s nomera 79529048819. Summa 3000.00 RUB. Balans 94.87 RUB.',
          identifier: { phone: '79232005555' },
          app: 'SMS Forwarder'
        }
      end

      response '201', 'запись входящего запроса создана' do
        it 'creates an incoming request record with actual data' do |example|
          expect { submit_request(example.metadata) }.to change {
            IncomingRequest.count
          }.from(0).to(1)
        end
      end
    end
  end
end
