require 'rails_helper'

feature 'Client can fill out the withdrawal form', type: :feature do
  let!(:rate_snapshot) { create(:rate_snapshot) }
  let!(:advertisement) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
  let!(:payment) { create(:payment, :withdrawal, :created, advertisement: advertisement) }

  before do
    visit "/payments/withdrawals/#{payment.uuid}?signature=#{payment.signature}"
  end

  scenario 'client not chosen payment system and try to confirm withdrawal' do
    select('Выбрать', from: 'withdrawal_payment_system')

    click_on 'Подтвердить'

    expect(page).to have_content('Платёжная система не выбрана')

    payment.reload

    expect(payment.payment_status).to eq('draft')
  end

  scenario 'client chosen payment system but not fill in card number, and try to confirm withdrawal' do
    select('Sberbank', from: 'withdrawal_payment_system')
    fill_in 'withdrawal_card_number', with: ''

    click_on 'Подтвердить'

    expect(page).to have_content('Номер карты неверной длины (может быть длиной ровно 16 символов)')

    payment.reload

    expect(payment.payment_status).to eq('draft')
  end

  scenario 'client entered valid attributes' do
    select('Sberbank', from: 'withdrawal_payment_system')
    fill_in 'withdrawal_card_number', with: '1111111111111111'

    click_on 'Подтвердить'

    expect(page).to have_content('Идёт подготовка платежа')
    expect(page).to have_content('Ожидайте пожалуйста...')
    expect(page).to have_content("uuid: #{payment.uuid}")

    payment.reload

    expect(payment.payment_status).to eq('processer_search')
  end
end