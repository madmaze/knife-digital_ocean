require 'spec_helper'
require 'chef/knife/digital_ocean_account_info'

describe Chef::Knife::DigitalOceanAccountInfo do
  let(:account_info_mock) do
    double('account_info_mock',
      uuid: 'b6fr89dbf6d9156cace5f3c78dc9851d957381ef',
      email: 'sammy@digitalocean.com',
      droplet_limit: 25,
      email_verified: true)
  end

  describe '#run' do
    it 'calls the right account method' do
      expect(subject).to receive_message_chain('client.account.info')
        .and_return account_info_mock
      expect(subject).to receive(:validate!)
      subject.run
    end
  end
end
