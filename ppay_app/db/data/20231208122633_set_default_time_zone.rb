# frozen_string_literal: true

class SetDefaultTimeZone < ActiveRecord::Migration[7.0]
  def up
    User.find_each do |user|
      user.update(time_zone: 'Moscow') if user.time_zone.blank?
    end
  end
end
