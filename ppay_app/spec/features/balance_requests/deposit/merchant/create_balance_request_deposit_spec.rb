# frozen_string_literal: true

require 'rails_helper'

feature 'Merchant can create new balance request', type: :feature do
  let!(:merchant) { create(:merchant) }

  before do
    visit '/users/sign_in'
    fill_in 'Email', with: merchant.email
    fill_in 'Пароль', with: merchant.password
    click_on 'Вход'
    visit '/balance_requests'
  end

  scenario 'merchant logs in, opens a balance requests page and try to
    create new balance request with empty amount' do
    expect(page).to have_link('+ Создать запрос')

    click_on '+ Создать запрос'

    expect(page).to have_content('Тип')
    expect(page).to have_content('Сумма')
    expect(page).to have_content('Криптоадрес USDT TRC20')
    expect(page).to have_button('Сохранить')

    select('Внесение', from: 'balance_request_requests_type')

    click_on 'Сохранить'

    expect(page).to have_content('не является числом')
    expect(merchant.balance_requests.size).to eq(0)
  end

  scenario 'merchant logs in, opens a balance requests page and try to
    create new balance request with amount equal to 0' do
    expect(page).to have_link('+ Создать запрос')

    click_on '+ Создать запрос'

    select('Внесение', from: 'balance_request_requests_type')

    fill_in 'Сумма', with: 0

    click_on 'Сохранить'

    expect(page).to have_content('может иметь значение большее 0')
    expect(merchant.balance_requests.size).to eq(0)
  end

  scenario 'merchant logs in, opens a balance requests page and try to
    create new balance request with valid attributes' do
    expect(page).to have_link('+ Создать запрос')

    click_on '+ Создать запрос'

    select('Внесение', from: 'balance_request_requests_type')

    fill_in 'balance_request_amount', with: 100

    click_on 'Сохранить'

    expect(page).to have_content("Запрос баланса (ID: #{merchant.balance_requests.last.id})")
    expect(page).to have_content("Переведите 100.0 USDT на кошелёк #{merchant.crypto_wallet.address}")
    expect(page).to have_content("Тип deposit")
    expect(merchant.balance_requests.size).to eq(1)

    merchant.balance_requests.last.complete!

    merchant.reload

    expect(merchant.balance.amount.to_i).to eq(1100)
  end
end
