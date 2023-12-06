# frozen_string_literal: true

require 'rails_helper'

def wait_for_ajax
  max_time = Capybara::Helpers.monotonic_time + Capybara.default_max_wait_time
  while Capybara::Helpers.monotonic_time < max_time
    finished = finished_all_ajax_requests?
    break if finished

    sleep 0.1
  end
  raise 'wait_for_ajax timeout' unless finished
end

def finished_all_ajax_requests?
  page.evaluate_script(<<~EOS
    ((typeof window.jQuery === 'undefined')
     || (typeof window.jQuery.active === 'undefined')
     || (window.jQuery.active === 0))
    && ((typeof window.injectedJQueryFromNode === 'undefined')
     || (typeof window.injectedJQueryFromNode.active === 'undefined')
     || (window.injectedJQueryFromNode.active === 0))
    && ((typeof window.httpClients === 'undefined')
     || (window.httpClients.every(function (client) { return (client.activeRequestCount === 0); })))
  EOS
                      )
end

feature 'All roles can change own time zone', js: true do
  context 'admin' do
    let!(:user) { create(:user, :admin) }
    before do
      visit '/users/sign_in'
      fill_in 'Email', with: user.email
      fill_in 'Пароль', with: user.password
      click_on 'Вход'
    end

    scenario 'logs in, opens setting page and selects own time zone' do
      find_link(href: users_settings_path).click
      expect(page).to have_content('Часовой пояс')
      select('Alaska', from: 'user_time_zone')
      wait_for_ajax
      expect(user.reload.time_zone).to eq('Alaska')
    end
  end

  context 'merchant' do
    let!(:user) { create(:merchant) }
    before do
      visit '/users/sign_in'
      fill_in 'Email', with: user.email
      fill_in 'Пароль', with: user.password
      click_on 'Вход'
    end

    scenario 'logs in, opens setting page and selects own time zone' do
      find_link(href: users_settings_path).click
      expect(page).to have_content('Часовой пояс')
      select('Alaska', from: 'user_time_zone')
      wait_for_ajax
      expect(user.reload.time_zone).to eq('Alaska')
    end
  end

  context 'processer' do
    let!(:user) { create(:processer) }
    before do
      visit '/users/sign_in'
      fill_in 'Email', with: user.email
      fill_in 'Пароль', with: user.password
      click_on 'Вход'
    end

    scenario 'logs in, opens setting page and selects own time zone' do
      find_link(href: users_settings_path).click
      expect(page).to have_content('Часовой пояс')
      select('Alaska', from: 'user_time_zone')
      wait_for_ajax
      expect(user.reload.time_zone).to eq('Alaska')
    end
  end

  context 'support' do
    let!(:user) { create(:support) }
    before do
      visit '/users/sign_in'
      fill_in 'Email', with: user.email
      fill_in 'Пароль', with: user.password
      click_on 'Вход'
    end

    scenario 'logs in, opens setting page and selects own time zone' do
      find_link(href: users_settings_path).click
      expect(page).to have_content('Часовой пояс')
      select('Alaska', from: 'user_time_zone')
      wait_for_ajax
      expect(user.reload.time_zone).to eq('Alaska')
    end
  end

  context 'working group' do
    let!(:user) { create(:working_group) }
    before do
      visit '/users/sign_in'
      fill_in 'Email', with: user.email
      fill_in 'Пароль', with: user.password
      click_on 'Вход'
    end

    scenario 'logs in, opens setting page and selects own time zone' do
      find_link(href: users_settings_path).click
      expect(page).to have_content('Часовой пояс')
      select('Alaska', from: 'user_time_zone')
      wait_for_ajax
      expect(user.reload.time_zone).to eq('Alaska')
    end
  end

  context 'ppay' do
    let!(:user) { create(:user, :ppay) }
    before do
      visit '/users/sign_in'
      fill_in 'Email', with: user.email
      fill_in 'Пароль', with: user.password
      click_on 'Вход'
    end

    scenario 'logs in, opens setting page and selects own time zone' do
      find_link(href: users_settings_path).click
      expect(page).to have_content('Часовой пояс')
      select('Alaska', from: 'user_time_zone')
      wait_for_ajax
      expect(user.reload.time_zone).to eq('Alaska')
    end
  end

  context 'super admin' do
    let!(:user) { create(:user, :super_admin) }
    before do
      visit '/users/sign_in'
      fill_in 'Email', with: user.email
      fill_in 'Пароль', with: user.password
      click_on 'Вход'
    end

    scenario 'logs in, opens setting page and selects own time zone' do
      find_link(href: users_settings_path).click
      expect(page).to have_content('Часовой пояс')
      select('Alaska', from: 'user_time_zone')
      wait_for_ajax
      expect(user.reload.time_zone).to eq('Alaska')
    end
  end

  context 'agent' do
    let!(:user) { create(:user, :agent) }
    before do
      visit '/users/sign_in'
      fill_in 'Email', with: user.email
      fill_in 'Пароль', with: user.password
      click_on 'Вход'
    end

    scenario 'logs in, opens setting page and selects own time zone' do
      find_link(href: users_settings_path).click
      expect(page).to have_content('Часовой пояс')
      select('Alaska', from: 'user_time_zone')
      wait_for_ajax
      expect(user.reload.time_zone).to eq('Alaska')
    end
  end
end
