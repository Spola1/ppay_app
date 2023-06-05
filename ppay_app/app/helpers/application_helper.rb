# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def navbar_collection
    Settings.navbar[current_user.type.underscore]
  end

  def hotlist_payments(user)
    user.payments.in_hotlist.decorate
  end

  def country_flag_icon(locale)
    country_code = locale_to_country_code(locale)
    flag_icon(country_code)
  end

  private

  def locale_to_country_code(locale)
    locale_to_country_code_map = {
      en: 'gb',
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
end
