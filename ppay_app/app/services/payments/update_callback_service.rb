# frozen_string_literal: true

require 'net/http'

module Payments
  class UpdateCallbackService < ApplicationService
    attr_reader :payment

    def initialize(payment)
      @payment = payment.decorate
    end

    def call
      response = Net::HTTP.post(uri, request, headers)

      save_payment_callback(response)
    end

    private

    def save_payment_callback(response)
      payment.payment_callbacks.create(
        sent_at: Time.now,
        response_status: response.code,
        response_body: response.body,
        request:
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
