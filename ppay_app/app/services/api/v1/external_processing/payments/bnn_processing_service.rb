require 'httparty'
require 'digest/md5'
require 'json'

module Api
  module V1
    module ExternalProcessing
      module Payments
        class BnnProcessingService
          def initialize(uid, private_key, object)
            @uid = uid
            @private_key = private_key
            @object = object
          end

          def get_banks
            timestamp = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S')

            banks_params = { timestamp: timestamp }

            sorted_params = banks_params.sort.map { |k, v| "#{k}=#{v}" }.join('&')
            signature_body = "#{@uid}:#{@private_key}:#{sorted_params}"

            banks_url = "https://bnn-pay.com/api/banks?#{sorted_params}"

            banks_headers = {
              'UID' => @uid,
              'SIGNATURE' => Digest::MD5.hexdigest(signature_body),
              'Content-Type' => 'application/json'
            }

            HTTParty.get(banks_url, body: banks_params, headers: banks_headers)
          end

          def create_order(order_id, amount)
            timestamp = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S')

            banks_response = get_banks
            banks_size = banks_response['Result'].size

            order_params = {
              orderId: order_id,
              amount: amount,
              callbackUrl: "#{ENV.fetch('EXTERNAL_BNN_CALLBACK_PROTOCOL')}://#{ENV.fetch('EXTERNAL_BNN_CALLBACK_ADDRESS')}/#{ENV.fetch('EXTERNAL_BNN_CALLBACK_PATH')}",
              returnUrl: "#{ENV.fetch('EXTERNAL_BNN_CALLBACK_PROTOCOL')}://#{ENV.fetch('EXTERNAL_BNN_CALLBACK_ADDRESS')}/#{ENV.fetch('EXTERNAL_BNN_CALLBACK_PATH')}",
              bankId: rand(1..banks_size)
            }.to_json

            create_order_url = "https://bnn-pay.com/api/order/create?timestamp=#{timestamp}"

            order_headers = {
              'UID' => @uid,
              'SIGNATURE' => Digest::MD5.hexdigest("#{@uid}:#{@private_key}:#{order_params}"),
              'Content-Type' => 'application/json'
            }

            HTTParty.post(create_order_url, body: order_params, headers: order_headers)
          end

          def get_payinfo(order_hash)
            timestamp = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S')

            get_order_params = { hash: order_hash, timestamp: timestamp }

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

              puts "Response Code: #{get_order_response.code}"
              puts "Response Body: #{get_order_response.body}"

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
        end
      end
    end
  end
end