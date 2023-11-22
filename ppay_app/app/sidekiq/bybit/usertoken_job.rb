# frozen_string_literal: true

module Bybit
  class UsertokenJob
    include Sidekiq::Job
    sidekiq_options queue: 'low', tags: ['bybit_usertoken']

    def perform
      in_progress_lock do
        break unless ENV.fetch('BYBIT_EMAIL', nil)
        break if usertoken_live?

        bybit_portal.settings['usertoken'] = bybit_usertoken

        bybit_portal.save if usertoken.present?
      end
    end

    def bybit_portal = @bybit_portal ||= ExchangePortal.find_by_name('Bybit P2P')

    def usertoken = bybit_portal.settings['usertoken']

    def otc = OtcOnline.new(usertoken)

    def usertoken_live?
      return false unless usertoken.present?

      otc.items({ pay_type: '75' }).present?
    end

    def bybit_usertoken = `cd tmp; ../bin/bybit_usertoken`.strip.lines.last&.[](/\A[[:graph:]]+\Z/)

    def in_progress_lock
      bybit_portal.with_lock do
        return if bybit_portal.in_progress

        bybit_portal.update(in_progress: true)
      end

      yield
    ensure
      bybit_portal.update(in_progress: false)
    end
  end
end
