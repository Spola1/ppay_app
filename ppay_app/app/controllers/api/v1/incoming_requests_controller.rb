module Api
  module V1
    class IncomingRequestsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        incoming_data = JSON.parse(request.body.read)
        @incoming_request = IncomingRequest.new(incoming_request_params(incoming_data))

        if @incoming_request.save
          find_matching_advertisement
          find_matching_payment
          payment_message

          render json: { status: 'success', message: 'Запрос успешно сохранен' }, status: :created
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

      def find_matching_advertisement
        search_fields = {
          'smsdeliverer' => { search_field: :imsi },
          'SMS Forwarder' => {
            'SMS' => { search_field: :phone },
            'PUSH' => { search_field: :imei }
          }
        }

        app = @incoming_request.app
        request_type = @incoming_request.request_type
        search_value = search_fields.dig(app, request_type)
        return unless search_value

        search_field = search_value[:search_field]
        search_value = @incoming_request.send(search_field)

        @matching_advertisements = Advertisement.where("imei = :value OR imsi = :value OR phone = :value",
                                                       value: search_value, simbank_auto_confirmation: true)

        card_number_masks = Mask.where(sender: @incoming_request.from, regexp_type: 'Номер счёта')

        @advertisement = nil

        @matching_advertisements.each do |advertisement|
          card_number_masks.each do |mask|
            regexp = eval(mask.regexp)
            field_to_check = @incoming_request.content || @incoming_request.message
            match = field_to_check.scan(regexp).first

            @advertisement = advertisement if match.include?(advertisement.simbank_card_number)
          end
        end
      end

      def find_matching_payment
        amount_masks = Mask.where(sender: @incoming_request.from, regexp_type: 'Сумма')

        @payment = nil

        if @advertisement.present?
          @advertisement.payments.for_simbank.each do |payment|
            amount_masks.each do |mask|
              regexp = eval(mask.regexp)
              field_to_check = @incoming_request.content || @incoming_request.message
              match = field_to_check.scan(regexp).first

              @payment = payment

              @payment.confirm! if match.include?(payment.decorate.national_formatted)
            end
          end
        end
      end

      def payment_message
        if @payment.present?
          text = "#{@incoming_request.created_at}\n"

          text += "#{@incoming_request.message}\n" if @incoming_request.message
          text += "#{@incoming_request.content}\n" if @incoming_request.content

          @incoming_request.attributes.each do |attr, value|
            next if value.nil? || %w[id created_at updated_at message content].include?(attr)

            text += "#{attr}: #{value}\n"
          end

          text += 'симбанк подтвердил подтвердил платеж согласно этому сообщению'

          @payment.comments.create!(
            author_nickname: 'SIM-банк',
            author_type: 'Processor',
            user_id: @payment.processer.id,
            text: text
          )
        end
      end
    end
  end
end
