# frozen_string_literal: true

require 'net/http'

module Payments
  class UpdateCallback < ApplicationService
    attr_reader :callback_url, :uuid, :external_order_id, :payment_status

    def initialize(*args)
      @callback_url, @uuid, @external_order_id, @payment_status = args
    end

    def call
      uri = URI(callback_url)
      body = { uuid:, external_order_id:, payment_status: }
      headers = { 'Content-Type': 'application/json' }
      Net::HTTP.post(uri, body.to_json, headers)
    end
  end
end
