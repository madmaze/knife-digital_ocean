require 'spec_helper'
require 'chef/knife/digital_ocean_domain_record_list'

describe Chef::Knife::DigitalOceanDomainRecordList do

  before :each do
    Chef::Knife::DigitalOceanDomainRecordList.load_deps
    subject.config[:name] = 'kitchen-digital.org'
  end

  describe '#run' do
    it 'should validate the Digital Ocean config keys exist' do
      VCR.use_cassette('domain_record_list') do
        expect(subject).to receive(:validate!)
        subject.run
      end
    end

    it 'should output the column headers' do
      VCR.use_cassette('domain_record_list') do
        expect(subject).to receive(:puts).with(/^ID\s+Type\s+Name\s+Data/)
        subject.run
      end
    end

    it 'should output a list of the available Digital Ocean domains' do
      VCR.use_cassette('domain_record_list') do
        expect(subject).to receive(:puts).with(/\b3364507\s+A\s+www\s+192.168.1.1\s+\n/)
        subject.run
      end
    end
  end
end
