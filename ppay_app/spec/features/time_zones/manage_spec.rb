# frozen_string_literal: true

require 'rails_helper'

feature 'All roles can change own time zone', type: :feature do
  context 'admin' do
    let!(:admin) { create(:user, :admin) }
    before do
      visit '/users/sign_in'
      fill_in 'Email', with: admin.email
      fill_in 'Пароль', with: admin.password
      click_on 'Вход'
    end

    scenario 'admin logs in, opens setting page and selects own time zone' do
      expect(page).to have_link('Настройки')
      click_on 'Настройки'
      expect(page).to have_content('Часовой пояс')
      select('Alaska', from: 'user_time_zone')
      expect(page).to have_content('Alaska')

      # expect(Admin.first.time_zone).to eq('Alaska')
    end
  end
end
