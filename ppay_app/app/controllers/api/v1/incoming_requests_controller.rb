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
      rescue StandardError => e
        @incoming_request = IncomingRequest.create(initial_params: request.raw_post, error: e.full_message)

        render json: { status: 'error', message: 'Ошибка при сохранении запроса' }, status: :unprocessable_entity
      end

      private

      def set_incoming_data
        @incoming_data =
          if from_macrodroid? || params[:body]
            body = from_macrodroid? ? params[:raw_json] : params[:body]

            JSON.parse(sanitized_params(body))
          else
            params.permit!.to_h
          end
      end

      def from_macrodroid?
        request.user_agent.match?(/macrodroid/)
      end

      def sanitized_params(body)
        CGI.unescape(body).gsub(/"content":\s?"(.*?)",[\S\s]*"identifier"/m) do |_match|
          content_value = ::Regexp.last_match(1).gsub(/\n/, ' ').gsub(/"/, '\"')
          "\"content\": \"#{content_value}\",\"identifier\""
        end
      end

      def find_api_key(data)
        return unless data['app'] == 'Telegram'

        app = TelegramApplication.find(data['main_application_id'])

        app.processer.token
      end

      def find_sender(data)
        if data['app'] == 'Telegram'
          TelegramBot.where(chat_id: data['from']).last.name
        else
          data['from']
        end
      end

      def incoming_request_params(data)
        {
          app: data['app'],
          api_key: data['api_key'] || find_api_key(data),
          request_type: data['type'],
          request_id: data['id'],
          from: find_sender(data),
          to: data['to'],
          message: CGI.unescape(data['message'] || data['content']),
          res_sn: data['res_sn'],
          identifier: data['identifier']&.keys&.first,
          imsi: data['imsi'] || data.dig('identifier', 'imsi'),
          imei: data['imei'] || data.dig('identifier', 'imei'),
          phone: data.dig('identifier', 'phone'),
          telegram_phone: data['telegram_phone'],
          com: data['com'],
          simno: data['simno'],
          softwareid: data['softwareid'],
          custmemo: data['custmemo'],
          sendstat: data['sendstat'],
          user_agent: data['user_agent'],
          user: user(data['api_key'] || find_api_key(data)),
          initial_params: request.raw_post
        }
      end

      def user(api_key)
        ApiKey.find_by(token: api_key)&.bearer
      end
    end
  end
end
