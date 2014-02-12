require 'webmock/rspec'

GEM_ROOT = Gem::Specification.find_by_name('clicoder').gem_dir
FIXTURE_DIR = GEM_ROOT + '/fixtures'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, 'http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=0001')
      .with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'})
      .to_return(:status => 200, :body => File.read("#{FIXTURE_DIR}/webmock/aoj/get_description_0001_body.html"), :headers => {})
  end
end
