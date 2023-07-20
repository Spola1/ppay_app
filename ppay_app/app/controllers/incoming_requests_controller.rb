# frozen_string_literal: true

class IncomingRequestsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    incoming_data = JSON.parse(request.body.read)

    app_name = incoming_data['app']
    request_type = incoming_data['type']

    @incoming_request = IncomingRequest.new(
      app: app_name,
      api_key: incoming_data['api_key'],
      request_type: request_type,
      request_id: incoming_data['id'],
      from: incoming_data['from'],
      to: incoming_data['to'],
      message: incoming_data['message'],
      res_sn: incoming_data['res_sn'],
      imsi: incoming_data['imsi'],
      imei: incoming_data['imei'],
      com: incoming_data['com'],
      simno: incoming_data['simno'],
      softwareid: incoming_data['softwareid'],
      custmemo: incoming_data['custmemo'],
      sendstat: incoming_data['sendstat'],
      user_agent: incoming_data['user_agent'],
      text: incoming_data['text'],
      content: incoming_data['content']
    )

    if @incoming_request.save
      render json: { status: 'success', message: 'Запрос успешно сохранен' }, status: :created
    else
      render json: { status: 'error', message: 'Ошибка при сохранении запроса' }, status: :unprocessable_entity
    end
  end

  private

  def process_push_request(request)
    # ..........................
  end

  def process_sms_request(request)
    # ..........................
  end
end