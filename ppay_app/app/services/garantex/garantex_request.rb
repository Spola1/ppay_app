# frozen_string_literal: true

module Garantex
  module GarantexRequest
    def self.send_get(token, link, form_data_hash)
      puts "send_get: #{link} #{form_data_hash}"

      host = 'garantex.org'
      custom_headers = { 'Authorization' => "Bearer #{token}" }
      uri = URI.parse("https://#{host}/api/v2/#{link}")

      response = Net::HTTP.start uri.hostname, uri.port, use_ssl: true,
                                                         open_timeout: 60, read_timeout: 60 do |http|
        request = Net::HTTP::Get.new uri.request_uri
        custom_headers.each { |key, value| request[key] = value }
        request.set_form_data(form_data_hash)
        http.request request
      end
      case response
      when Net::HTTPSuccess, Net::HTTPRedirection
        JSON.parse(response.body)
      else
        response.value
      end
    end
  end
end
