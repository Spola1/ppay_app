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
    create new balance request with empty amount and crypto address' do
    expect(page).to have_link('+ Создать запрос')

    click_on '+ Создать запрос'

    expect(page).to have_content('Тип')
    expect(page).to have_content('Сумма')
    expect(page).to have_content('Криптоадрес USDT TRC20')
    expect(page).to have_button('Сохранить')

    select('Снятие', from: 'balance_request_requests_type')

    click_on 'Сохранить'

    expect(page).to have_content('не является числом')
    expect(page).to have_content('не может быть пустым')
    expect(merchant.balance_requests.size).to eq(0)
  end

  scenario 'merchant logs in, opens a balance requests page and try to
    create new balance request with empty crypto address and amount equal to 0' do
    expect(page).to have_link('+ Создать запрос')

    click_on '+ Создать запрос'

    select('Снятие', from: 'balance_request_requests_type')

    fill_in 'Сумма', with: 0

    click_on 'Сохранить'

    expect(page).to have_content('может иметь значение большее 0')
    expect(page).to have_content('не может быть пустым')
    expect(merchant.balance_requests.size).to eq(0)
  end

  scenario 'merchant logs in, opens a balance requests page and try to
    create new balance request with valid attributes' do
    expect(page).to have_link('+ Создать запрос')

    click_on '+ Создать запрос'

    select('Снятие', from: 'balance_request_requests_type')

    fill_in 'balance_request_amount', with: 100
    fill_in 'balance_request_crypto_address', with: merchant.crypto_wallet.address

    click_on 'Сохранить'

    expect(page).to have_content("Запрос баланса (ID: #{merchant.balance_requests.last.id})")
    expect(page).to have_content("Тип withdraw")

    merchant.reload

    expect(merchant.balance.amount.to_i).to eq(900)
  end
end
