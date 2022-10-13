# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RsaEncryptionService, type: :service do
  let(:data) { 'test rsa' }

  describe '#public_encrypt' do
    subject { described_class.new(data, Settings.rsa.public_key).public_encrypt }

    let(:decrypted_subject) { described_class.new(subject, Settings.rsa.private_key).decrypt }

    it 'returns decryptable data' do
      expect(decrypted_subject).to eq(data)
    end
  end

  describe '#public_decrypt' do
    subject { described_class.new(encrypted_data, Settings.rsa.public_key).public_decrypt }

    let(:encrypted_data) { described_class.new(data, Settings.rsa.private_key).encrypt }

    it 'returns string "test rsa"' do
      is_expected.to eq(data)
    end
  end

  describe '#encrypt' do
    subject { described_class.new(data, Settings.rsa.private_key).encrypt }

    let(:decrypted_subject) { described_class.new(subject, Settings.rsa.public_key).public_decrypt }

    it 'returns decryptable data' do
      expect(decrypted_subject).to eq(data)
    end
  end

  describe '#decrypt' do
    subject { described_class.new(encrypted_data, Settings.rsa.private_key).decrypt }

    let(:encrypted_data) { described_class.new(data, Settings.rsa.public_key).public_encrypt }

    it 'returns string "test rsa"' do
      is_expected.to eq(data)
    end
  end
end
