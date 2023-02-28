require 'rails_helper'

feature 'Processor can confirm deposit', type: :feature do
  let!(:rate_snapshot) { create(:rate_snapshot) }
  let!(:advertisement) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
  let!(:payment) { create(:payment, :deposit, :confirming, advertisement: advertisement) }

  before do
    visit '/users/sign_in'
    fill_in 'Email', with: advertisement.processer.email
    fill_in 'Пароль', with: advertisement.processer.password
    click_on 'Вход'
    visit "/payments/deposits/#{payment.uuid}"
  end

  scenario 'processer logs in, opens a new deposit and confirms it' do
    expect(page).to have_content('Данные платежа')
    expect(page).to have_button('Подтвердить')

    click_on 'Подтвердить'

    expect(page).to have_content('Завершён')

    payment.reload
    advertisement.processer.reload

    expect(payment.payment_status).to eq('completed')
  end
end
