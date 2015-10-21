require 'spec_helper'
require 'chef/knife/digital_ocean_droplet_create'
require 'droplet_kit'

describe Chef::Knife::DigitalOceanDropletCreate do
  let(:config) do
    {
      digital_ocean_access_token: 'FAKE',
      server_name: 'sever-name.example.com',
      image: 11_111,
      location: 22_222,
      size: 33_333,
      ssh_key_ids: [44_444, 44_445],
      bootstrap: true
    }
  end

  let(:client_create_response) do
    {
      id: '123'
    }
  end

  context 'bootstrapping for chef-server' do
    describe 'the bootstrap class' do
      before do
        allow(subject).to receive(:config).and_return config

        allow(subject).to receive_message_chain(:client, :droplets, :create)
          .and_return double('droplets create response', client_create_response)

        allow(subject).to receive_message_chain(:client, :droplets, :find, :status).and_return 'new'

        allow(subject).to receive(:ip_address_available).and_return '123.123.123.123'
        allow(subject).to receive(:tcp_test_ssh).and_return true
      end

      it 'uses the right bootstrap class' do
        expect(subject.bootstrap_class).to eql(Chef::Knife::Bootstrap)
      end

      it 'calls #run on the bootstrap class' do
        allow_any_instance_of(Chef::Knife::Bootstrap).to receive(:run)
        expect { subject.run }.not_to raise_error
      end
    end
  end

  context 'bootstrapping for knife-solo' do
    describe 'when knife-solo is installed' do
      let(:solo_bootstrapper) do
        double('solo bootstrapper').as_null_object
      end

      before do
        # simulate installed knife-solo gem
        stub_const('Chef::Knife::SoloBootstrap', solo_bootstrapper)
        expect(subject).to receive(:config).at_least(:once).and_return config.update(solo: true)
      end

      it 'should use the right bootstrap class' do
        expect(subject.bootstrap_class).to eql(Chef::Knife::SoloBootstrap)
      end
    end

    describe 'when knife-solo is not installed' do
      before do
        # simulate knife-solo gem is not installed
        Chef::Knife.send(:remove_const, :SoloBootstrap) if defined?(Chef::Knife::SoloBootstrap)
        expect(subject).to receive(:config).at_least(:once).and_return config.update(solo: true)
      end

      it 'should not create a droplet' do
        expect(subject.client).not_to receive(:droplets)
        expect { subject.run }.to raise_error(SystemExit)
      end
    end
  end

  context 'no bootstrapping' do
    describe 'should not do any bootstrapping' do
      before do
        expect(subject).to receive(:config).at_least(:once).and_return config.update(bootstrap: false)

        allow(subject).to receive_message_chain(:client, :droplets, :create)
          .and_return double('droplets create response', client_create_response)

        allow(subject).to receive_message_chain(:client, :droplets, :find, :status).and_return 'new'
        expect(subject).to receive(:ip_address_available).and_return '123.123.123.123'
        expect(subject).to receive(:tcp_test_ssh).and_return true
      end

      it 'should not call #bootstrap_for_node' do
        expect(subject).not_to receive(:bootstrap_for_node)
        expect { subject.run }.to raise_error
      end

      it 'should have a 0 exit code' do
        expect { subject.run }.to raise_error(SystemExit)
      end
    end
  end

  context 'passing json attributes (-j)' do
    let(:json_attributes) do
      '{ "apache": { "listen_ports": 80 } }'
    end

    before do
      expect(subject).to receive(:config).at_least(:once).and_return config.update(json_attributes: json_attributes)
    end

    it 'should configure the first boot attributes on Bootstrap' do
      bootstrap = subject.bootstrap_for_node('123.123.123.123')
      expect(bootstrap.config[:first_boot_attributes]).to eql(json_attributes)
    end
  end

  context 'passing secret_file (--secret-file)' do
    let(:secret_file) { '/tmp/sekretfile' }

    before do
      expect(subject).to receive(:config).at_least(:once).and_return config.update(secret_file: secret_file)
    end

    it 'secret_file should be available to Bootstrap' do
      bootstrap = subject.bootstrap_for_node('123.123.123.123')
      expect(bootstrap.config[:secret_file]).to eql(secret_file)
    end
  end

  context 'passing ssh_port (--ssh-port)' do
    let(:ssh_port) { 22 }

    before do
      expect(subject).to receive(:config).at_least(:once).and_return config.update(ssh_port: ssh_port)
    end

    it 'ssh_port should be available to Bootstrap' do
      bootstrap = subject.bootstrap_for_node('123.123.123.123')
      expect(bootstrap.config[:ssh_port]).to eql(ssh_port)
    end
  end
end
