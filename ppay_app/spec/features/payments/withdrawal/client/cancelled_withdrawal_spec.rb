# frozen_string_literal: true

require 'rails_helper'

feature 'Client can cancel withdrawal', type: :feature do
  let!(:payment) { create(:payment, :withdrawal, :created) }

  before do
    visit "/payments/withdrawals/#{payment.uuid}?signature=#{payment.signature}"
  end

  scenario 'client cancels withdrawal' do
    click_on 'Отменить платёж'

    expect(page).to have_content('Платёж отменён!')
    expect(page).to have_content("uuid: #{payment.uuid}")
    expect(page).to have_link('вернуться в магазин', href: payment.redirect_url.to_s)

    payment.reload

    expect(payment.payment_status).to eq('cancelled')
  end
end
