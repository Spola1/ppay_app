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
            @timestamp = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S')
            @logs = []
          end

          def get_banks
            banks_params = { timestamp: @timestamp }

            sorted_params = banks_params.sort.map { |k, v| "#{k}=#{v}" }.join('&')
            signature_body = "#{@uid}:#{@private_key}:#{sorted_params}"

            banks_url = "https://bnn-pay.com/api/banks?#{sorted_params}"

            banks_headers = {
              'UID' => @uid,
              'SIGNATURE' => Digest::MD5.hexdigest(signature_body),
              'Content-Type' => 'application/json'
            }

            banks_response = HTTParty.get(banks_url, body: banks_params, headers: banks_headers)

            @logs << { type: 'banks_response', body: banks_response.body, code: banks_response.code }
            banks_response
          end

          def create_order(order_id, amount)
            banks_response = get_banks
            banks_size = banks_response['Result'].size

            settings_path = Rails.root.join('config', 'settings.yml')
            settings = YAML.load_file(settings_path)
            callback_path = settings['external_callback_path']

            order_params = {
              orderId: order_id,
              amount: amount,
              callbackUrl: "#{ENV.fetch('EXTERNAL_BNN_CALLBACK_PROTOCOL')}://#{ENV.fetch('EXTERNAL_BNN_CALLBACK_ADDRESS')}/#{callback_path}",
              bankId: rand(1..banks_size)
            }.to_json

            create_order_url = "https://bnn-pay.com/api/order/create?timestamp=#{@timestamp}"

            order_headers = {
              'UID' => @uid,
              'SIGNATURE' => Digest::MD5.hexdigest("#{@uid}:#{@private_key}:#{order_params}"),
              'Content-Type' => 'application/json'
            }

            create_order_response = HTTParty.post(create_order_url, body: order_params, headers: order_headers)

            @logs << { type: 'create_order_response', body: create_order_response.body, code: create_order_response.code }
            create_order_response
          end

          def get_payinfo(order_hash)
            get_order_params = { hash: order_hash, timestamp: @timestamp }

            get_order_sorted_params = get_order_params.sort.map { |k, v| "#{k}=#{v}" }.join('&')
            signature_body = "#{@uid}:#{@private_key}:#{get_order_sorted_params}"

            get_payinfo_url = "https://bnn-pay.com/api/order/payinfo?#{get_order_sorted_params}"

            get_order_headers = {
              'UID' => @uid,
              'SIGNATURE' => Digest::MD5.hexdigest(signature_body),
              'Content-Type' => 'application/json'
            }

            10.times do
              get_order_response = HTTParty.get(get_payinfo_url, headers: get_order_headers)

              @logs << { type: 'get_payinfo_response', body: get_order_response.body, code: get_order_response.code }

              if get_order_response['Result']['IsActive'] == true
                @object.update(
                  payment_system: get_order_response['Result']['cardDetail']['Bank'],
                  card_number: get_order_response['Result']['cardDetail']['Card'],
                  other_processing_id: order_hash
                )
                break
              end

              sleep(1)
            end
          end

          def save_logs(order_hash)
            PaymentLog.create(
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