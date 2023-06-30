# frozen_string_literal: true

require 'rake'

def silence_stream(stream)
  old_stream = stream.dup
  stream.reopen(File::NULL)
  stream.sync = true

  yield
ensure
  stream.reopen(old_stream)
  old_stream.close
end

RSpec.configure do |config|
  config.before(:suite) do
    unless PaymentSystem.count.positive?
      Rails.application.load_tasks

      silence_stream($stdout) { Rake::Task['data:migrate'].invoke }
    end
  end
end
