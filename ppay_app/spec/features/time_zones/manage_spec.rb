# frozen_string_literal: true

require 'rails_helper'

def wait_for_ajax
  max_time = Capybara::Helpers.monotonic_time + Capybara.default_max_wait_time
  while Capybara::Helpers.monotonic_time < max_time
    finished = finished_all_ajax_requests?
    if finished
      break
    else
      sleep 0.1
    end
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

feature 'All roles can change own time zone' do
  context 'admin' do
    let!(:admin) { create(:user, :admin) }
    before do
      visit '/users/sign_in'
      fill_in 'Email', with: admin.email
      fill_in 'Пароль', with: admin.password
      click_on 'Вход'
    end

    scenario 'admin logs in, opens setting page and selects own time zone' do
      find_link(href: users_settings_path).click
      expect(page).to have_content('Часовой пояс')
      select('Alaska', from: 'user_time_zone')
      expect(page).to have_select('user_time_zone', selected: '(GMT-09:00) Alaska')

      # expect(admin.reload.time_zone).to eq('Alaska')
    end
  end

  context 'merchant' do
    let!(:merchant) { create(:merchant) }
    before do
      visit '/users/sign_in'
      fill_in 'Email', with: merchant.email
      fill_in 'Пароль', with: merchant.password
      click_on 'Вход'
    end

    scenario 'merchant logs in, opens setting page and selects own time zone' do
      find_link(href: users_settings_path).click
      expect(page).to have_content('Часовой пояс')
      # expect(page).to have_select('user_time_zone', selected: merchant.time_zone)
      select('Alaska', from: 'user_time_zone')
      # wait_for_ajax
      expect(page).to have_select('user_time_zone', selected: '(GMT-09:00) Alaska')
      # expect(merchant.reload.time_zone).to eq('Alaska')
    end
  end
end
