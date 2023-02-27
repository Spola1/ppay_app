require 'rails_helper'

feature 'Client can cancel payment', type: :feature do
  let!(:payment) { create(:payment, :deposit, :created) }

  before do
    visit "/payments/deposits/#{payment.uuid}?signature=#{payment.signature}"
  end

  scenario 'client cancels payment' do
    click_on 'Отменить платеж'

    expect(page).to have_content('Платеж отменён !')
    expect(page).to have_content("uuid: #{payment.uuid}")
    expect(page).to have_link('вернуться в магазин', href: "#{payment.redirect_url}")

    payment.reload

    expect(payment.payment_status).to eq('cancelled')
  end
end