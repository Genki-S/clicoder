require 'webmock/rspec'

GEM_ROOT = Gem::Specification.find_by_name('clicoder').gem_dir
FIXTURE_DIR = GEM_ROOT + '/fixtures'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # Use around hook to execute stub_request before other around hooks
  config.around(:each) do |example|
    stub_request(:get, 'http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=0001')
      .with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'})
      .to_return(:status => 200, :body => File.read("#{FIXTURE_DIR}/webmock/aoj/get_description_0001_body.html"), :headers => {})

    stub_request(:post, "http://judge.u-aizu.ac.jp/onlinejudge/servlet/Submit")
      .with(
        :body => {
          "userID"=>"",
          "password"=>"",
          "language"=>"C++",
          "problemNO"=>"0001",
          "sourceCode"=>File.read("#{FIXTURE_DIR}/clicoder.d/template.cpp"),
          "submit"=>"Send",
        },
        :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'Host'=>'judge.u-aizu.ac.jp', 'User-Agent'=>'Ruby'}
      )
      .to_return(:status => 200, :body => 'UserID or Password is Wrong.', :headers => {})

    stub_request(:post, "http://judge.u-aizu.ac.jp/onlinejudge/servlet/Submit")
      .with(
        :body => {
          "userID"=>"Glen_S",
          "password"=>"pass",
          "language"=>"C++",
          "problemNO"=>"0001",
          "sourceCode"=>File.read("#{FIXTURE_DIR}/clicoder.d/template.cpp"),
          "submit"=>"Send",
        },
        :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'Host'=>'judge.u-aizu.ac.jp', 'User-Agent'=>'Ruby'}
      )
      .to_return(:status => 200, :body => '', :headers => {})

    example.run
  end
end
