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
    code = telegram_application.code

    script_command = "python3 tg.py #{api_id} #{api_hash} #{session_name} #{phone_number}"
    stdin, stdout, _stderr, wait_thr = Open3.popen3(script_command)

    puts stdout.readpartial(4096)

    Thread.new do
      loop do
        puts stdout.readpartial(4096)
      end
    end

    stdin.puts(phone_number)
    stdin.flush

    loop { stdin.puts gets.chomp }
    wait_thr.join

    sleep(30)

    telegram_application.reload

    stdin.puts(code)
    stdin.flush
  end
end
