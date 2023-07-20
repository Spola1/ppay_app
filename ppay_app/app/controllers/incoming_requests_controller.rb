# frozen_string_literal: true

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
      @matching_advertisements = Advertisement.where("imei = :imei OR imsi = :imsi OR phone = :phone",
                                                      imei: @incoming_request.imei,
                                                      imsi: @incoming_request.imsi,
                                                      phone: @incoming_request.phone)

      masks = Mask.where(regexp_type: 'Номер счёта')

      @advertisement = nil

      @matching_advertisements.each do |advertisement|
        masks.each do |mask|
          regexp = eval(mask.regexp)
          field_to_check = @incoming_request.content || @incoming_request.message
          match = field_to_check.scan(regexp).first

          if match.include?(advertisement.simbank_card_number)
            @advertisement = advertisement
          end
        end
      end

      debugger

      render json: { status: 'success', message: 'Запрос успешно сохранен' }, status: :created
    else
      render json: { status: 'error', message: 'Ошибка при сохранении запроса' }, status: :unprocessable_entity
    end
  end

  private

  def process_push_request(request)

  end

  def process_sms_request(request)

  end
end