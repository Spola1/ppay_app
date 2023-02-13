# frozen_string_literal: true

require 'net/http'

module Payments
  class UpdateCallback < ApplicationService
    attr_reader :callback_url, :uuid, :external_order_id, :payment_status, :token

    def initialize(payment)
      @callback_url = payment.callback_url
      @uuid = payment.uuid
      @external_order_id = payment.external_order_id
      @payment_status = payment.payment_status
      @token = payment.merchant.token
    end

    def call
      uri = URI(callback_url)
      body = { uuid:, external_order_id:, payment_status: }.compact
      headers = {
        'Content-Type':  'application/json',
        'Authorization': "Bearer #{token}"
      }
      Net::HTTP.post(uri, body.to_json, headers)
    end
  end
end
