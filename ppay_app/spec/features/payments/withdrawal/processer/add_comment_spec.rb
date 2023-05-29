# frozen_string_literal: true

require 'rails_helper'

feature 'Processer can add comments to withdrawal' do
  let!(:rate_snapshot) { create(:rate_snapshot) }
  let!(:advertisement) { create(:advertisement, :withdrawal, payment_system: 'Sberbank') }
  let!(:payment) { create(:payment, :withdrawal, :transferring, advertisement:) }

  before do
    visit '/users/sign_in'
    fill_in 'Email', with: advertisement.processer.email
    fill_in 'Пароль', with: advertisement.processer.password
    click_on 'Вход'
    visit "/payments/withdrawals/#{payment.uuid}"
  end

  scenario 'processer adds comment to withdrawal' do
    fill_in 'comment_text', with: 'My new comment'
    click_on 'Добавить комментарий'

    expect(page).to have_content 'My new comment'
  end
end
