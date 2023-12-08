# frozen_string_literal: true

require 'rails_helper'

feature 'Time zone settings:', js: true do
  %i[admin super_admin ppay agent merchant processer support working_group].each do |user_type|
    context user_type do
      let(:user) { create user_type }

      before do
        sign_in user
        visit root_path
      end

      scenario 'selects own time zone' do
        expect(user.reload.time_zone).to eq('Moscow')

        find_link(href: users_settings_path).click

        expect(page).to have_content('Часовой пояс')
        select('Alaska', from: 'user_time_zone')

        expect(page).to have_content('Часовой пояс')
        expect(user.reload.time_zone).to eq('Alaska')
      end
    end
  end
end
