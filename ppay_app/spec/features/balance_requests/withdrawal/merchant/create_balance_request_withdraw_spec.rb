# frozen_string_literal: true

require 'rails_helper'

feature 'Balance requests', js: true do
  let!(:merchant) { create(:merchant) }

  before do
    sign_in merchant
    visit '/balance_requests'
  end

  scenario 'merchant tries to create with empty amount and crypto address' do
    click_on '+ Создать запрос'

    select('Снятие', from: 'balance_request_requests_type')

    click_on 'Сохранить'

    expect(page).to have_content('не является числом')
    expect(page).to have_content('не может быть пустым')

    expect(merchant.balance_requests.size).to eq(0)
  end

  scenario 'merchant tries to create with empty crypto address and amount equal to 0' do
    click_on '+ Создать запрос'

    select('Снятие', from: 'balance_request_requests_type')

    fill_in 'Сумма', with: 0

    click_on 'Сохранить'

    expect(page).to have_content('может иметь значение большее 0')
    expect(page).to have_content('не может быть пустым')
    expect(merchant.balance_requests.size).to eq(0)
  end

  scenario 'merchant tries to create with valid attributes' do
    click_on '+ Создать запрос'

    select('Снятие', from: 'balance_request_requests_type')

    fill_in 'balance_request_amount_minus_commission', with: 97
    fill_in 'balance_request_crypto_address', with: merchant.crypto_wallet.address

    click_on 'Сохранить'

    expect(page).to have_content('Тип withdraw')
    expect(page).to have_content("Запрос баланса (ID: #{merchant.reload.balance_requests.last.id})")
    expect(page).to have_content('Сумма 100.0 USDT')
    expect(page).to have_content('Вы получите 97.0 USDT')

    expect(merchant.balance.amount.to_i).to eq(900)
  end

  scenario 'merchant can not hack commissions', js: false do
    click_on '+ Создать запрос'

    select('Снятие', from: 'balance_request_requests_type')

    fill_in 'balance_request_amount', with: 100
    fill_in 'balance_request_amount_minus_commission', with: 100
    fill_in 'balance_request_crypto_address', with: merchant.crypto_wallet.address

    click_on 'Сохранить'

    expect(page).to have_content('Тип withdraw')
    expect(page).to have_content("Запрос баланса (ID: #{merchant.reload.balance_requests.last.id})")
    expect(page).to have_content('Сумма 100.0 USDT')
    expect(page).to have_content('Вы получите 97.0 USDT')

    expect(merchant.balance.amount.to_i).to eq(900)
  end
end
