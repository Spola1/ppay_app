# frozen_string_literal: true

require 'swagger_helper'
require 'rails_helper'

describe 'Deposits' do
  include_context 'authorization'

  let!(:rate_snapshot) { create(:rate_snapshot) }

  path '/api/v1/payments/deposits' do
    post 'Создание депозита' do
      tags 'Платежи'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: {}]

      description File.read(Rails.root.join('spec/support/swagger/markdown/v1/payments/deposits.md'))

      let(:payment_type) { Deposit }

      it_behaves_like 'create_payment'
    end
  end
end

RSpec.describe "Deposit page", type: :feature do
  context "User not select payment_system" do
    let(:payment) { create(:payment, :deposit, :created) }

    before do
      visit "/payments/deposits/#{payment.uuid}?signature=#{payment.signature}"
    end

    it "shows flash message when payment system is not selected" do
      select "Выбрать", from: "deposit_payment_system"
      click_button "Подтвердить"

      expect(page).to have_content("Платёжная система не выбрана")
      expect(payment.payment_status).to eq("created")
    end
  end

  context "User select payment_system" do
    let(:payment)   { create(:payment, :deposit, :created) }
    let(:processer) { create(:processer) }
    let(:advertisement) { create(:advertisement, processer: processer) }

    before do
      visit "/payments/deposits/#{payment.uuid}?signature=#{payment.signature}"
    end

    it "update payment status to processer_search" do
      select "AlfaBank", from: "deposit_payment_system"
      click_button "Подтвердить"

      p page.html

      expect { payment.search }.to change(payment, :payment_status).from('created').to('processer_search')
    end
  end

  context "User cancelled payment" do
    let(:payment) { create(:payment, :deposit, :created) }

    before do
      visit "/payments/deposits/#{payment.uuid}?signature=#{payment.signature}"
    end

    it "shows flash message when payment system is not selected" do
      click_button "Отменить платеж"

      p page.html

      expect(page).to have_content("UID Check
                                    Платеж отменён !
                                    вернуться в магазин
                                    uuid: #{payment.uuid}")
      expect(payment.payment_status).to eq("created")
    end
  end
end
