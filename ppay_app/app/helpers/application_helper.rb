# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def navbar_collection
    Settings.navbar[current_user.type.underscore]
  end

  def hotlist_payments(user)
    user.payments.in_hotlist.decorate
  end

  private

  def locale_to_country_code(locale)
    locale_to_country_code_map = {
      id: 'id',
      kk: 'kz',
      ky: 'kg',
      ru: 'ru',
      tg: 'tj',
      tr: 'tr',
      uk: 'ua',
      uz: 'uz'
    }

    locale_to_country_code_map[locale.to_sym]
  end

  def active?(name)
    name == action_name ? :active : nil
  end
end
