require 'spec_helper'
require 'chef/knife/digital_ocean_sshkey_list'

describe Chef::Knife::DigitalOceanSshkeyList do

  before :each do
    Chef::Knife::DigitalOceanSshkeyList.load_deps
    allow(subject).to receive(:puts)
  end

  describe '#run' do
    it 'should validate the Digital Ocean config keys exist' do
      VCR.use_cassette('sshkey') do
        expect(subject).to receive(:validate!)
        subject.run
      end
    end

    it 'should output the column headers' do
      VCR.use_cassette('sshkey') do
        expect(subject).to receive(:puts).with(/^ID\s+Name\s+Fingerprint\s+\n/)
        subject.run
      end
    end

    it 'should output a list of the available Digital Ocean ssh keys' do
      VCR.use_cassette('sshkey') do
        expect(subject).to receive(:puts).with(/\bgregf\b/)
        subject.run
      end
    end
  end
end
