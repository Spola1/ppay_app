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

          def initialize(uid, private_key, object)
            @uid = uid
            @private_key = private_key
            @object = object
            @logs = []
          end

          def timestamp = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S')
          def signature(content) = Digest::MD5.hexdigest("#{@uid}:#{@private_key}:#{content}")

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

              if response['Result']['IsActive']
                @object.update(
                  payment_system: response['Result']['cardDetail']['Bank'],
                  card_number: response['Result']['cardDetail']['Card'],
                  other_processing_id: hash
                )
                break
              end

              sleep(1)
            end
          end

          def save_logs(order_hash)
            @object.payment_logs.create(
              banks_response: logs.find { |log| log[:type] == 'banks_response' }&.to_json,
              create_order_response: logs.find { |log| log[:type] == 'create_order_response' }&.to_json,
              payinfo_responses: logs.select { |log| log[:type] == 'get_payinfo_response' }&.to_json,
              other_processing_id: order_hash
            )
          end
        end
      end
    end
  end
end
