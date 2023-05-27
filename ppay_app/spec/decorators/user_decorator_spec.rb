# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserDecorator do
  let(:user) { create :merchant, name:, surname:, nickname:, email: }
  let(:name) { 'Name' }
  let(:surname) { 'Surname' }
  let(:nickname) { 'n1ckn4mE' }
  let(:email) { 'e@ma.il' }

  subject(:decorated) { user.decorate }

  describe '#human_type' do
    subject { decorated.human_type }
    it { is_expected.to eq I18n.t('activerecord.attributes.user/type.merchant') }
  end

  describe '#display_name' do
    subject { decorated.display_name }

    it { is_expected.to eq user.nickname }

    context 'When nickname = nil' do
      let(:nickname) { nil }
      it { is_expected.to eq decorated.full_name }
    end

    context 'when nickname, name and surname = nil' do
      let(:name) { nil }
      let(:surname) { nil }
      let(:nickname) { nil }
      it { is_expected.to eq decorated.display_id }
    end
  end

  describe '#full_name' do
    subject { decorated.full_name }

    it { is_expected.to eq [name, surname].join(' ') }

    context 'When name = nil' do
      let(:name) { nil }
      it { is_expected.to eq surname }
    end

    context 'When surname = nil' do
      let(:surname) { nil }
      it { is_expected.to eq name }
    end

    context 'When name and surname = nil' do
      let(:name) { nil }
      let(:surname) { nil }
      it { is_expected.to be_empty }
    end
  end

  describe '#display_id' do
    subject { decorated.display_id }
    it { is_expected.to eq "ID: #{user.id}" }
  end

  describe '#audit_user_info' do
    subject { decorated.audit_user_info }
    it { is_expected.to eq "#{decorated.human_type} #{decorated.display_name} (#{email})" }
  end
end
