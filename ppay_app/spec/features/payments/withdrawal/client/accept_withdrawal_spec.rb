# frozen_string_literal: true

require 'rails_helper'

feature 'Client can confirm withdrawal', type: :feature do
  let!(:payment) { create :payment, :withdrawal, :confirming }

  before do
    visit "/payments/withdrawals/#{payment.uuid}?signature=#{payment.signature}"
  end

  xscenario 'client confirm withdrawal' do
    expect(page).to have_content('Вы получили деньги?')
    expect(page).to have_button('Подтвердить')
    expect(page).to have_content("uuid: #{payment.uuid}")

    click_on 'Подтвердить'

    expect(page).to have_content('Успешно!')
    expect(page).to have_content('Платёж выполнен!')

    payment.reload

    expect(payment.payment_status).to eq('completed')
  end
end
