# frozen_string_literal: true

module DashboardHelper
  GREEN_COLOR = 'text-green-500'.freeze
  RED_COLOR = 'text-red-500'.freeze

  def conversion_color(value)
    value >= 50 ? GREEN_COLOR : RED_COLOR
  end

  def average_confirmation_color(value)
    value >= 60 ? RED_COLOR : GREEN_COLOR
  end

  def balance_color(value)
    value > 150 ? GREEN_COLOR : RED_COLOR
  end

  def merchants_collection
    Merchant.all.map { |merchant| [merchant.nickname, merchant.id] }
  end

  def active_advertisements_list(advertisements)
    advertisements.group_by(&:payment_system).map do |payment_system, advertisements|
      "#{payment_system}: #{advertisements.count}"
    end.join('<br />').html_safe
  end

  def periods_collection
    [['Последний час', 'last_hour'],
     ['Последние 3 часа', 'last_3_hours'],
     ['Последние 6 часов', 'last_6_hours'],
     ['Последние 12 часов', 'last_12_hours'],
     ['Последние 24 часа', 'last_day'],
     ['Последние 3 дня', 'last_3_days'],
     ['Вчера', 'yesterday'],
     ['Позавчера', 'before_yesterday']]
  end

  def dashboard_filters_partial(user)
    if user.processer?
      'shared/staff/dashboard/filters'
    else
      'shared/staff/management/dashboard/filters'
    end
  end
end
