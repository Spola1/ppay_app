# frozen_string_literal: true

class IncomingRequestsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @incoming_request = IncomingRequest.new(incoming_request_params)

    if @incoming_request.save
      render json: { status: 'success', message: 'Запрос успешно сохранен' }, status: :created
    else
      render json: { status: 'error', message: 'Ошибка при сохранении запроса' }, status: :unprocessable_entity
    end
  end

  private

  def incoming_request_params
    params.require(:body).permit(
      :type, :app, :api_key, :from, :to, :message, :res_sn,
      :imsi, :imei, :com, :simno, :softwareid, :custmemo, :sendstat,
      :user_agent, :text, :content
    )
  end
end