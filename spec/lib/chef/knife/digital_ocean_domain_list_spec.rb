require 'spec_helper'
require 'chef/knife/digital_ocean_domain_list'

describe Chef::Knife::DigitalOceanDomainList do

  before :each do
    Chef::Knife::DigitalOceanDomainList.load_deps
    allow(subject).to receive(:puts)
  end

  describe '#run' do
    it 'should validate the Digital Ocean config keys exist' do
      VCR.use_cassette('domain_list') do
        expect(subject).to receive(:validate!)
        subject.run
      end
    end

    it 'should output the column headers' do
      VCR.use_cassette('domain_list') do
        expect(subject).to receive(:puts).with(/^Name\s+TTL/)
        subject.run
      end
    end

    it 'should output a list of the available Digital Ocean domains' do
      VCR.use_cassette('domain_list') do
        expect(subject).to receive(:puts).with(/\bgregf.org\s+1800\n/)
        subject.run
      end
    end
  end
end
