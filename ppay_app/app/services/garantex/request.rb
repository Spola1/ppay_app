# frozen_string_literal: true

module Garantex
  module GarantexRequest
    def self.send_get(token, link, form_data_hash)
      host = 'garantex.io'
      custom_headers = { 'Authorization' => "Bearer #{token}" }
      uri = URI.parse("https://#{host}/api/v2/#{link}")

      response = Net::HTTP.start uri.hostname, uri.port, use_ssl: true do |http|
        request = Net::HTTP::Get.new uri.request_uri
        custom_headers.each { |key, value| request[key] = value }
        request.set_form_data(form_data_hash)
        http.request request
      end
      case response
      when Net::HTTPSuccess, Net::HTTPRedirection
        JSON.parse(response.body)
        # puts "response_hash: #{response_hash}"

      else
        response.value
      end
      # return nil unless Net::HTTPResponse === response # Error occured
      # return nil unless Net::HTTPOK === response # HTTP error with code
      # return nil unless response.body # Response is empty
    end
  end
end
