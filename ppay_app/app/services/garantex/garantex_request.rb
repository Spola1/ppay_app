# frozen_string_literal: true

require 'async/http/faraday'

module Garantex
  module GarantexRequest
    def build_conn(token)
      Faraday.new do |builder|
        builder.adapter :async_http, timeout: 60
        builder.request :json
        builder.request :authorization, 'Bearer', -> { token }
        builder.response :json
      end
    end

    def self.send_get(token, link, form_data_hash)
      puts "send_get: #{link} #{form_data_hash}"
      host = 'garantex.org'
      url = "https://#{host}/api/v2/#{link}"
      res = build_conn(token).get(url, form_data_hash)
      res.body
    end
  end
end
