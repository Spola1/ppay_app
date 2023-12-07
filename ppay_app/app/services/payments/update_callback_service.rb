# frozen_string_literal: true

require 'net/http'

module Payments
  class UpdateCallbackService < ApplicationService
    attr_reader :payment

    def initialize(payment)
      @payment = payment.decorate
    end

    def call
      save_payment_callback_before_send
      response = Net::HTTP.post(uri, request, headers)
      update_payment_callback_after_response(response)
    end

    private

    def save_payment_callback_before_send
      payment.payment_callbacks.create(
        request:
      )
    end

    def update_payment_callback_after_response(response)
      payment_callback = payment.payment_callbacks.last
      payment_callback.update(
        response_at: Time.now,
        response_status: response.code,
        response_body: response.body
      )
    end

    def uri
      URI(payment.callback_url)
    end

    def request
      serializer.new(payment).serializable_hash.to_json
    end

    def serializer
      "Api::V1::Payments::UpdateCallback::#{payment.type}Serializer".constantize
    end

    def headers
      {
        'Content-Type': 'application/json',
        Authorization: "Bearer #{token}"
      }
    end

    def token
      payment.merchant.token
    end
  end
end
