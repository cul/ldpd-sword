# require 'rails_helper'

RSpec.describe Sword::Utils::Logging do
  describe '.log_received_deposit_post' do
    it 'calls Rails.logger.warn with correct info' do
      expect(Rails.logger).to receive(:warn).with(/Username: sample_depositor/)
      described_class.log_received_deposit_post('collection/_slug', 'sample_depositor_id', 'sample/path')
    end
  end

  describe '.log_deposit_result_info' do
    it 'calls Rails.logger.warn with correct info' do
      expect(Rails.logger).to receive(:warn).with(/asset pids: cul:987654321/)
      described_class.log_deposit_result_info('A Title', 'file.txt', 'cul:123456789', 'cul:987654321', '/tmp/sword')
    end
  end
end
