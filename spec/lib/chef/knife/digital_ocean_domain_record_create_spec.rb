require 'spec_helper'
require 'chef/knife/digital_ocean_domain_record_create'

describe Chef::Knife::DigitalOceanDomainRecordCreate do

  before :each do
    Chef::Knife::DigitalOceanDomainRecordCreate.load_deps
    allow(subject).to receive(:puts)
    subject.config[:domain] = 'kitchen-digital.org'
    subject.config[:type] = 'A'
    subject.config[:name] = 'www'
    subject.config[:data] = '192.168.1.1'
  end

  describe '#run' do
    it 'should validate the Digital Ocean config keys exist' do
      VCR.use_cassette('domain_record_create') do
        expect(subject).to receive(:validate!)
        subject.run
      end
    end

    it 'should create the domain record and exit with 0' do
      VCR.use_cassette('domain_record_create') do
        allow(subject.client).to receive_message_chain(:domain_records, :create)
        expect { subject.run }.not_to raise_error
      end
    end

    # TODO: Figure out why this is now failing
    # it 'should return OK' do
    #   VCR.use_cassette('domain_record_create') do
    #     expect($stdout).to receive(:puts).with('OK')
    #     expect(subject.run).to eq nil
    #   end
    # end
  end
end
