# frozen_string_literal: true

class BalanceRequestUrlUtility
  include Rails.application.routes.url_helpers

  attr_reader :balance_request

  def initialize(balance_request)
    @balance_request = balance_request
  end

  def url
    balance_request_url(balance_request)
  end
end
