module Api
  module V1
    class IncomingRequestsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        incoming_data = JSON.parse(request.body.read)
        @incoming_request = IncomingRequest.new(incoming_request_params(incoming_data))

        if @incoming_request.save
          service = IncomingRequestService.new(@incoming_request)
          response = service.process_request

          render json: response, status: :created
        else
          render json: { status: 'error', message: 'Ошибка при сохранении запроса' }, status: :unprocessable_entity
        end
      end

      private

      def incoming_request_params(data)
        {
          app: data['app'],
          api_key: data['api_key'],
          request_type: data['type'],
          request_id: data['id'],
          from: data['from'],
          to: data['to'],
          message: data['message'],
          res_sn: data['res_sn'],
          identifier: data['identifier']&.keys&.first,
          imsi: data['imsi'] || data['identifier']['imsi'],
          imei: data['imei'] || data['identifier']['imei'],
          phone: data['identifier']&.[]('phone'),
          com: data['com'],
          simno: data['simno'],
          softwareid: data['softwareid'],
          custmemo: data['custmemo'],
          sendstat: data['sendstat'],
          user_agent: data['user_agent'],
          content: data['content']
        }
      end
    end
  end
end