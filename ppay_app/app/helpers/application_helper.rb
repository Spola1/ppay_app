# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def navbar_collection
    Settings.navbar[current_user.type.underscore]
  end

  def hotlist_payments(user)
    user.payments.in_hotlist.decorate
  end

  def deposit_hotlist_advertisements(user)
    subquery = user.advertisements.left_outer_joins(:payments).merge(Payment.in_deposit_flow_hotlist)

    Advertisement.where(id: subquery)
                 .or(user.advertisements.active)
                 .by_direction('Deposit')
                 .order('payment_system ASC')
  end

  def withdrawal_hotlist_advertisements(user)
    subquery = user.advertisements.left_outer_joins(:payments).merge(Payment.in_withdrawal_flow_hotlist)

    Advertisement.where(id: subquery)
                 .or(user.advertisements.active)
                 .by_direction('Withdrawal')
                 .order('payment_system ASC')
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

  def action_active?(name)
    name == action_name ? :active : nil
  end

  def controller_active?(name)
    name == controller_name ? :active : nil
  end
end
