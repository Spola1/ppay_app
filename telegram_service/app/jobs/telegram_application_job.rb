# frozen_string_literal: true

require 'open3'

class TelegramApplicationJob
  include Sidekiq::Job
  sidekiq_options queue: 'default', tags: ['telegram_application']

  def perform(id)
    telegram_application = TelegramApplication.find(id)

    api_id = telegram_application.api_id
    api_hash = telegram_application.api_hash
    session_name = telegram_application.session_name
    phone_number = telegram_application.phone_number
    main_application_id = telegram_application.main_application_id
    telegram_bots = telegram_application.bot_names
    telegram_bots_str = telegram_bots.join("")

    script_command = "python3 tg.py #{api_id} #{api_hash} #{session_name} #{main_application_id} #{phone_number} #{telegram_bots_str}"
    stdin, stdout, _stderr, wait_thr = Open3.popen3(script_command)

    puts stdout.readpartial(4096)

    Thread.new do
      loop do
        puts stdout.readpartial(4096)
      end
    end

    stdin.puts(phone_number)

    loop do
      break if telegram_application.code.present?

      sleep(3)

      telegram_application.reload
    end

    stdin.puts(telegram_application.code)
    stdin.flush

    loop { stdin.puts gets.chomp }
    wait_thr.join
  end
end
