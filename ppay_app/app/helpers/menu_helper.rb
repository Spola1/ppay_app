# frozen_string_literal: true

module MenuHelper
  def link_with_arbitration_check(link)
    link_text = link.name

    link_text += " #{arbitration_count_text}" if link.name == 'Арбитражи по чеку'

    link_to link_text.html_safe, public_send(link[:path])
  end

  private

  def arbitration_count_text
    count = calculate_arbitration_count
    content_tag(:span, count.to_s, class: 'text-white bg-red-600 py-1.5 px-1.5 rounded-md') if count.positive?
  end

  def calculate_arbitration_count
    if current_user.support?
      Payment.includes(:merchant).arbitration_by_check.size
    else
      current_user.payments.arbitration_by_check.size
    end
  end
end
