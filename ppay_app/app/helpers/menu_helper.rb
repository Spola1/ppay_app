# frozen_string_literal: true

module MenuHelper
  def menu_links(link)
    link_text = link.name

    link_text += " #{arbitration_count_text}" if link.name == 'Арбитражи по чеку'

    link_to link_text.html_safe, public_send(link[:path])
  end

  private

  def arbitration_count_text
    count = calculate_arbitration_count

    if current_user.support?
      render('shared/support_arbitration_count', count:)
    else
      render('shared/arbitration_count', count:, user: current_user)
    end
  end

  def calculate_arbitration_count
    if current_user.support?
      Payment.arbitration_by_check.size
    else
      current_user.payments.arbitration_by_check.size
    end
  end
end
