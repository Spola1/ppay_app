# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserDecorator do
  let(:user) { create :user, :merchant, name:, nickname: }
  let(:name) { 'Artur' }
  let(:nickname) { 'JustKing' }

  describe '#human_type' do
    it 'should return Мерчант if type Merchant' do
      expect(user.decorate.human_type).to eq 'Мерчант'
    end
  end

  describe '#display_name' do
    context 'When nickname, name annd surname = nil' do
      let(:name) { nil }
      let(:nickname) { nil }
      it 'should return ID if nickname = nil and full_name = nil' do
        expect(user.decorate.display_name).to eq "ID: #{user.id}"
      end
    end

    context 'When nickname = nil' do
      let(:nickname) { nil }
      it 'should return full_name if nickname not presence' do
        expect(user.decorate.display_name).to eq user.decorate.full_name
      end
    end

    it 'should return nickname' do
      expect(user.decorate.display_name).to eq user.nickname
    end
  end

  describe '#full_name' do
    it 'should return name + surname if one of the two precense' do
      expect(user.decorate.full_name).to eq 'Artur'
    end

    context 'When name and surname = nil' do
      let(:name) { nil }
      it 'should return false if name and surname not precense' do
        expect(user.decorate.full_name).to eq nil
      end
    end
  end

  describe '#display_id' do
    it 'should return ID' do
      expect(user.decorate.display_id).to eq "ID: #{user.id}"
    end
  end
end
