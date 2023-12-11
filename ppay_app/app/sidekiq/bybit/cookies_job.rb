# frozen_string_literal: true

module Bybit
  class CookiesJob
    include Sidekiq::Job
    sidekiq_options queue: 'low', tags: ['bybit_cookies']

    def perform
      in_progress_lock do
        break unless ENV.fetch('BYBIT_EMAIL', nil)
        break if cookies_live?

        bybit_portal.settings['cookies'] = bybit_cookies

        bybit_portal.save if cookies.present?
      end
    end

    def bybit_portal = @bybit_portal ||= ExchangePortal.find_by_name('Bybit P2P')

    def cookies = bybit_portal.settings['cookies']

    def otc = OtcOnline.new(cookies)

    def cookies_live?
      return false unless cookies.present?

      otc.items({ pay_type: '75' }).present?
    end

    def bybit_cookies = `cd tmp; ../bin/bybit_cookies`.strip.lines.last&.[](/\A\[\{.*\}\]\Z/)

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
