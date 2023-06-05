# frozen_string_literal: true

require 'rails_helper'

feature 'Merchant can log in', type: :feature do
  let!(:merchant) { create(:merchant) }

  before do
    visit '/users/sign_in'
  end

  scenario 'registered merchant tries to sign in' do
    fill_in 'Email', with: merchant.email
    fill_in 'Пароль', with: merchant.password

    click_on 'Вход'

    expect(page).to have_content('Вход в систему выполнен.')
    expect(page).to have_content('Все платежи')
    expect(page).to have_content('Запросы баланса')
    expect(page).to have_content("Баланс: #{merchant.balance.amount}")
  end

  scenario 'unregistered merchant tries to sign in' do
    fill_in 'Email', with: 'test@test.test'
    fill_in 'Пароль', with: 'test'

    click_on 'Вход'

    expect(page).to have_content('Неправильный Email или пароль.')
    expect(page).to have_content('Email')
    expect(page).to have_content('Пароль')
  end
end
