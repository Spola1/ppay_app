# frozen_string_literal: true

class TelegramConnectionDecorator < ApplicationDecorator
  delegate_all

  def status_with_color
    if object.status.present? && object.status == 'success' && object.updated_at > 11.seconds.ago
      connected_status
    else
      not_connected_status
    end
  end

  private

  def connected_status
    h.content_tag(:pre, h.content_tag(:span, 'Подключено', class: 'connected'))
  end

  def not_connected_status
    h.content_tag(:pre, h.content_tag(:span, 'Не подключено', class: 'not-connected'))
  end
end
