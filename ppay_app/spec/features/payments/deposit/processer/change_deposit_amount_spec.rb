# frozen_string_literal: true

require 'rails_helper'

feature 'Processer can change deposit amount', :sidekiq_inline, :silence_output, js: true do
  let!(:rate_snapshot) { create :rate_snapshot }
  let!(:ppay) { create :user, :ppay }
  let!(:merchant) { create :merchant, :with_mixed_balance_freeze_type, initial_balance: merchant_initial_balance }
  let!(:processer) { create :processer, initial_balance: processer_initial_balance }
  let!(:support) { create :support }
  let!(:advertisement) { create :advertisement, processer: }
  let(:merchant_initial_balance) { 1000 }
  let(:processer_initial_balance) { 1000 }
  let(:initial_national_currency_amount) { 3000 }
  let(:added_national_currency_amount) { 4000 }

  before do
    using_session 'Merchant' do
      sign_in merchant
      visit root_path
    end

    using_session 'Support' do
      sign_in support
      visit root_path
    end

    perform_enqueued_jobs do
      post '/api/v1/payments/deposits',
           params: {
             national_currency: 'RUB',
             national_currency_amount: initial_national_currency_amount,
             external_order_id: '1234',
             locale: 'ru',
             redirect_url: 'https://example.com/redirect_url',
             callback_url: 'https://example.com/callback_url'
           }.to_json,
           headers: { 'Accept' => 'application/json',
                      'Content-Type' => 'application/json',
                      'Authorization' => "Bearer #{merchant.token}" }
      deposit_url = response_body[:data][:attributes][:url]

      using_session 'Processer' do
        sign_in processer
        visit root_path
      end

      using_session 'Client' do
        visit deposit_url
        select('Sberbank', from: 'deposit_payment_system')

        click_on 'Подтвердить'

        attach_file 'spec/fixtures/test_files/sample.jpeg', make_visible: true
        click_on 'Оплата завершена'
      end

      using_session 'Processer' do
        first(:link_or_button, 'ДЕПОЗИТ').click
      end
    end
  end

  scenario 'processer changes the completed deposit amount' do
    perform_enqueued_jobs do
      using_session 'Processer' do
        accept_confirm { click_on 'Подтвердить' }
      end

      using_session 'Support' do
        click_on 'Все платежи'
        find('.fa-search').click

        accept_confirm { click_on 'Откатить платёж' }
      end

      using_session 'Processer' do
        fill_in 'national_currency_amount', with: added_national_currency_amount
        accept_confirm { click_on 'Изменить сумму' }

        processer.balance.withdraw(970)

        accept_confirm { click_on 'Подтвердить платёж' }
      end
    end
  end

  scenario 'processer changes the confirming deposit amount' do
    perform_enqueued_jobs do
      using_session 'Processer' do
        Deposit.first

        fill_in 'national_currency_amount', with: added_national_currency_amount
        accept_confirm { click_on 'Изменить сумму' }

        accept_confirm { click_on 'Подтвердить' }
      end
    end
  end
end
