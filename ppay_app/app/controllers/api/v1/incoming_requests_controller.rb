# frozen_string_literal: true

module Api
  module V1
    class IncomingRequestsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        set_incoming_data
        @incoming_request = IncomingRequest.new(incoming_request_params(@incoming_data))

        if @incoming_request.save && Setting.last.receive_requests_enabled && @incoming_request.user
          service = IncomingRequestService.new(@incoming_request)
          response = service.process_request

          render json: response, status: :created
        else
          render json: { status: 'error', message: 'Ошибка при сохранении запроса' }, status: :unprocessable_entity
        end
      end

      private

      def set_incoming_data
        if params[:body]
          body = CGI.unescape(params[:body])

          body.gsub!(/"content": "(.*?)"/m) do |_match|
            content_value = ::Regexp.last_match(1).gsub(/\n/, ' ')
            "\"content\": \"#{content_value}\""
          end

          @incoming_data = JSON.parse(body)
        else
          @incoming_data = params.permit!.to_h
        end
      end

      def incoming_request_params(data)
        {
          app: data['app'],
          api_key: data['api_key'],
          request_type: data['type'],
          request_id: data['id'],
          from: data['from'],
          to: data['to'],
          message: CGI.unescape(data['message'] || data['content']),
          res_sn: data['res_sn'],
          identifier: data['identifier']&.keys&.first,
          imsi: data['imsi'] || data.dig('identifier', 'imsi'),
          imei: data['imei'] || data.dig('identifier', 'imei'),
          phone: data.dig('identifier', 'phone'),
          com: data['com'],
          simno: data['simno'],
          softwareid: data['softwareid'],
          custmemo: data['custmemo'],
          sendstat: data['sendstat'],
          user_agent: data['user_agent'],
          user: user(data['api_key']),
          initial_params: params
        }
      end

      def user(api_key)
        ApiKey.find_by(token: api_key)&.bearer
      end
    end
  end
end
