module Api
  module V1
    class IncomingRequestsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        incoming_data = JSON.parse(request.body.read)

        @incoming_request = IncomingRequest.new(
          app: incoming_data['app'],
          api_key: incoming_data['api_key'],
          request_type: incoming_data['type'],
          request_id: incoming_data['id'],
          from: incoming_data['from'],
          to: incoming_data['to'],
          message: incoming_data['message'],
          res_sn: incoming_data['res_sn'],
          identifier: incoming_data['identifier']&.keys&.first,
          imsi: incoming_data['imsi'] || incoming_data['identifier']['imsi'],
          imei: incoming_data['imei'] || incoming_data['identifier']['imei'],
          phone: incoming_data['identifier']&.[]('phone'),
          com: incoming_data['com'],
          simno: incoming_data['simno'],
          softwareid: incoming_data['softwareid'],
          custmemo: incoming_data['custmemo'],
          sendstat: incoming_data['sendstat'],
          user_agent: incoming_data['user_agent'],
          content: incoming_data['content']
        )

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

      def find_matching_advertisement
        @matching_advertisements = Advertisement.where("imei = :imei OR imsi = :imsi OR phone = :phone",
                                                      imei: @incoming_request.imei,
                                                      imsi: @incoming_request.imsi,
                                                      phone: @incoming_request.phone)

        card_number_masks = Mask.where(regexp_type: 'Номер счёта')

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
        amount_masks = Mask.where(regexp_type: 'Сумма')

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

          @payment.comments.create(
            author_nickname: @payment.processer.nickname,
            author_type: 'Processor',
            user_id: @payment.processer.id,
            text: text
          )
        end
      end
    end
  end
end
