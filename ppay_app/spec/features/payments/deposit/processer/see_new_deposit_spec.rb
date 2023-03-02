# frozen_string_literal: true

require 'rails_helper'

feature 'Processor can see new deposit', type: :feature do
  context 'processer have advertisement for deposit' do
    let!(:rate_snapshot) { create(:rate_snapshot) }
    let!(:advertisement) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
    let!(:payment) { create(:payment, :deposit, :confirming, advertisement:) }

    before do
      visit '/users/sign_in'
      fill_in 'Email', with: advertisement.processer.email
      fill_in 'Пароль', with: advertisement.processer.password
      click_on 'Вход'
    end

    scenario 'processer sign in and see new payment' do
      expect(page).to have_content('Ждут ваших действий')
      expect(advertisement.processer.payments.size).to eq(1)
      expect(advertisement.processer.payments.first.payment_status).to eq('confirming')
    end
  end

  context 'processer has no advertisement for deposit' do
    let!(:rate_snapshot) { create(:rate_snapshot) }
    let!(:advertisement) { create(:advertisement, :deposit, payment_system: 'AlfaBank') }
    let!(:payment) { create(:payment, :deposit, :confirming) }

    before do
      visit '/users/sign_in'
      fill_in 'Email', with: advertisement.processer.email
      fill_in 'Пароль', with: advertisement.processer.password
      click_on 'Вход'
    end

    scenario 'processer sign in and see new payment' do
      expect(page).not_to have_content('Ждут ваших действий')
      expect(advertisement.processer.payments.size).to eq(0)
    end
  end
end
