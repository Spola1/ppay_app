# frozen_string_literal: true

module ProfilesHelper
  def telegram_hint
    ('Введите свое имя пользователя, перед этим перейдите по ссылке ' +
     link_to(ENV['TELEGRAM_BOT_LINK'], ENV['TELEGRAM_BOT_LINK'], target: '_blank', class: 'text-blue-600') +
     ' и нажмите Start').html_safe
  end
end
