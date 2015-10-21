$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'chef', 'knife'))
require 'hashie'
require 'vcr'
require 'rspec'
require 'chef/knife'
require 'coveralls'
require 'simplecov'
require 'simplecov-console'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('FAKE_ACCESS_TOKEN') { ENV['DIGITALOCEAN_ACCESS_TOKEN'] }

  c.before_record do |interaction|
    filter_headers(interaction, 'Set-Cookie', '_COOKIE_ID_')
  end
end

# Clear config between each example
# to avoid dependencies between examples
RSpec.configure do |c|
  c.before(:each) do
    Chef::Config.reset
    Chef::Config[:knife] = {}
    Chef::Config['knife']['digital_ocean_access_token'] = ENV['DIGITALOCEAN_ACCESS_TOKEN'] || 'FAKE_ACCESS_TOKEN'

    if subject.class.respond_to? :load_deps
      subject.class.load_deps
    end

    #allow(subject).to receive(:client).and_return client
  end
end

#SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
#  Coveralls::SimpleCov::Formatter,
#  SimpleCov::Formatter::HTMLFormatter,
#  SimpleCov::Formatter::Console
#]
SimpleCov.start

# Cleverly borrowed from knife-rackspace, thank you!
def filter_headers(interaction, pattern, placeholder)
  [interaction.request.headers, interaction.response.headers].each do |headers|
    sensitive_tokens = headers.select { |key| key.to_s.match(pattern) }
    sensitive_tokens.each do |key, _value|
      headers[key] = placeholder
    end
  end
end
