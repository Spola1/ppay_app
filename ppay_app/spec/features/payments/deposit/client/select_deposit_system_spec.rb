# frozen_string_literal: true

require 'rails_helper'

feature 'Client can select payment system', type: :feature do
  let!(:rate_snapshot) { create(:rate_snapshot) }
  let!(:advertisement) { create(:advertisement, payment_system: payment_system.name) }
  let!(:payment) { create(:payment, :deposit, :created, advertisement:) }

  before do
    visit "/payments/deposits/#{payment.uuid}?signature=#{payment.signature}"
  end

  scenario 'client not chosen payment system and try to confirm choise payment system' do
    select(I18n.t('payments.choise'), from: 'deposit_payment_system')

    click_on 'Подтвердить'

    expect(page).to have_content([I18n.t('activerecord.attributes.payment.payment_system'),
                                  I18n.t('errors.messages.invalid')].join(' '))

    payment.reload

    expect(payment.payment_status).to eq('draft')
  end

  scenario 'client chosen payment system and try to confirm choise payment system' do
    select(payment_system.name, from: 'deposit_payment_system')

    click_on 'Подтвердить'

    expect(page).to have_content('Идёт подготовка платежа')
    expect(page).to have_content('Ожидайте пожалуйста...')
    expect(page).to have_content("uuid: #{payment.uuid}")

    payment.reload

    expect(payment.payment_status).to eq('processer_search')
  end
end
