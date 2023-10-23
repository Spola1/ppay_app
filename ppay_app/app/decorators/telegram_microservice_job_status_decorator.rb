# frozen_string_literal: true

class TelegramMicroserviceJobStatusDecorator < ApplicationDecorator
  delegate_all

  def status_with_color
    if object.status == 'Подключено'
      h.content_tag(:pre, 'Статус: '.html_safe + h.content_tag(:span, object.status, class: 'connected'))
    else
      h.content_tag(:pre, 'Статус: '.html_safe + h.content_tag(:span, object.status, class: 'not-connected'))
    end
  end
end
