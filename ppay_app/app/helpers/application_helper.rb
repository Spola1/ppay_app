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

  def language_options
    {
      I18n.t('payments.locale.ru') => :ru,
      I18n.t('payments.locale.uz') => :uz,
      I18n.t('payments.locale.tg') => :tg,
      I18n.t('payments.locale.id') => :id,
      I18n.t('payments.locale.kk') => :kk,
      I18n.t('payments.locale.uk') => :uk,
      I18n.t('payments.locale.tr') => :tr,
      I18n.t('payments.locale.ky') => :ky
    }
  end

  def active?(name)
    name == action_name ? :active : nil
  end
end
