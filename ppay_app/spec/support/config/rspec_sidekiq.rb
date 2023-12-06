# frozen_string_literal: true

RSpec::Sidekiq.configure do |config|
  config.warn_when_jobs_not_processed_by_sidekiq = false
end

RSpec.configure do |config|
  config.around do |example|
    if example.metadata[:silence_output]
      silence_output
      example.run
      restore_output
    else
      example.run
    end
  end

  config.around do |example|
    if example.metadata[:sidekiq_inline]
      Sidekiq::Testing.inline! { example.run }
    else
      example.run
    end
  end
end

