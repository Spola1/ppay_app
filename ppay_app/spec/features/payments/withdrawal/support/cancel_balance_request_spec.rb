require 'rails_helper'

feature 'Support can cancel balance request', type: :feature do
  let!(:support) { create(:support) }
  let!(:balance_request) { create(:balance_request, :withdraw) }

  before do
    visit '/users/sign_in'
    fill_in 'Email', with: support.email
    fill_in 'Пароль', with: support.password
    click_on 'Вход'
    visit '/balance_requests'
  end

  scenario 'support logs in, opens a balance requests page, select balance request 
    and try to cancel balance request' do
    expect(page).to have_content('1')
    expect(page).to have_content('withdraw')
    expect(page).to have_content('1.0 USDT')
    expect(page).to have_content('processing')

    visit "/balance_requests/#{balance_request.id}"

    expect(page).to have_content("Запрос баланса (ID: #{balance_request.id})")
    expect(page).to have_link('Подтвердить или отказать ->')

    click_on 'Подтвердить или отказать ->'

    expect(page).to have_content('Редактировать')
    expect(page).to have_content("Запрос баланса (ID: #{balance_request.id})")

    select('Отменён', from: 'balance_request_status')

    click_on 'Сохранить'

    balance_request.reload

    expect(balance_request.status).to eq('cancelled')
  end
end
