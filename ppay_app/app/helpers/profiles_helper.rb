# frozen_string_literal: true

module ProfilesHelper
  def telegram_hint
    'Введите свое имя пользователя, перед этим перейдите по ссылке ' \
    "#{link_to_bot} и нажмите Start".html_safe
  end

  private

  def link_to_bot
    link_to(ENV.fetch('TELEGRAM_BOT_LINK', nil), ENV.fetch('TELEGRAM_BOT_LINK', nil), target: '_blank',
                                                                                      class: 'text-blue-600')
  end
end
