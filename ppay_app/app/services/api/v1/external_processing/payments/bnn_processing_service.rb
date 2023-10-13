# frozen_string_literal: true

require 'httparty'
require 'digest/md5'
require 'json'

module Api
  module V1
    module ExternalProcessing
      module Payments
        class BnnProcessingService
          attr_reader :logs

          def initialize
            @uid = Rails.application.credentials.bnn_pay[:uid]
            @private_key = Rails.application.credentials.bnn_pay[:private_key]
            @logs = []
          end

          def timestamp = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S')
          def signature(content) = Digest::MD5.hexdigest("#{@uid}:#{@private_key}:#{content}")

          def get_orders(hash)
            query_params = {
              hash:,
              exclude_expired: true,
              timestamp:
            }

            url = "https://bnn-pay.com/api/orders?#{query_params.to_query}"

            response = HTTParty.get(url, headers: headers(query_params.to_query))

            @logs << { type: 'orders_response', body: response.body, code: response.code }
            response
          end

          def headers(content)
            {
              'UID' => @uid,
              'SIGNATURE' => signature(content),
              'Content-Type' => 'application/json'
            }
          end

          def callback_url
            "#{ENV.fetch('EXTERNAL_BNN_CALLBACK_PROTOCOL')}://" \
              "#{ENV.fetch('EXTERNAL_BNN_CALLBACK_ADDRESS')}/#{Settings.external_callback_path}"
          end

          def banks
            @banks ||= begin
              query = { timestamp: }.to_query
              url = "https://bnn-pay.com/api/banks?#{query}"

              response = HTTParty.get(url, headers: headers(query))

              @logs << { type: 'banks_response', body: response.body, code: response.code }
              response
            end
          end

          def create_order(order_id, amount)
            params_json = {
              orderId: order_id,
              amount:,
              callbackUrl: callback_url,
              bankId: banks['Result'].sample['Id']
            }.to_json
            url = "https://bnn-pay.com/api/order/create?timestamp=#{timestamp}"

            response = HTTParty.post(url, body: params_json, headers: headers(params_json))

            @logs << { type: 'create_order_response', body: response.body, code: response.code }
            response
          end

          def payinfo(hash)
            query = { hash:, timestamp: }.to_query
            url = "https://bnn-pay.com/api/order/payinfo?#{query}"

            10.times do
              response = HTTParty.get(url, headers: headers(query))

              @logs << { type: 'get_payinfo_response', body: response.body, code: response.code }

              return response if response['Result']['IsActive']

              sleep(1)
            end
          end
        end
      end
    end
  end
end
