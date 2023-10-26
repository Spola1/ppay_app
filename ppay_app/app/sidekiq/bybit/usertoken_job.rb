# frozen_string_literal: true

module Bybit
  class UsertokenJob
    include Sidekiq::Job
    sidekiq_options queue: 'low', tags: ['bybit_usertoken']

    def perform
      return if usertoken_valid?
      return unless ENV.fetch('BYBIT_EMAIL', nil)

      bybit_portal.settings['usertoken'] = bybit_usertoken
      bybit_portal.save if /\A[[:graph:]]+\Z/ =~ usertoken
    end

    def bybit_portal = @bybit_portal ||= ExchangePortal.find_by_name('Bybit P2P')

    def usertoken = bybit_portal.settings['usertoken']

    def otc = OtcOnline.new(usertoken)

    def usertoken_valid? = otc.items({ pay_type: '75' }).present?

    def bybit_usertoken = `cd tmp; ../bin/bybit_usertoken`.strip
  end
end
