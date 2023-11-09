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
        # builder.response :raise_error
      end
    end

    def self.send_get(token, link, form_data_hash)
      puts "send_get: #{link} #{form_data_hash}"
      host = 'garantex.org'
      url = "https://#{host}/api/v2/#{link}"
      Async do
        body = build_conn(token).get(url, form_data_hash).body
        raise Faraday::Error, body['message'] unless body['success']

        body
      ensure
        Faraday.default_connection.close
      end
    end

    # def self.send_get1(token, link, form_data_hash)
    #   puts "send_get: #{link} #{form_data_hash}"

    #   host = 'garantex.org'
    #   custom_headers = { 'Authorization' => "Bearer #{token}" }
    #   uri = URI.parse("https://#{host}/api/v2/#{link}")

    #   response = Net::HTTP.start uri.hostname, uri.port, use_ssl: true,
    #                                                      open_timeout: 60, read_timeout: 60 do |http|
    #     request = Net::HTTP::Get.new uri.request_uri
    #     custom_headers.each { |key, value| request[key] = value }
    #     request.set_form_data(form_data_hash)
    #     http.request request
    #   end
    #   case response
    #   when Net::HTTPSuccess, Net::HTTPRedirection
    #     JSON.parse(response.body)
    #   else
    #     response.value
    #   end
    # end
  end
end
