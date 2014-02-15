require 'clicoder'
require 'clicoder/aoj'

Given /^AOJ is stubbed with webmock/ do
  # TODO: DRY. see spec/spec_helper.rb
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
end

Given /^in a problem directory of number (\d+)/ do |problem_number|
  aoj = Clicoder::AOJ.new(problem_number)
  aoj.start
  Dir.chdir(aoj.work_dir)
end

Given /^I don't have user_id and password/ do
  FileUtils.rm("#{ENV['HOME']}/.clicoder.d/config.yml")
end

Given /^outputs are wrong/ do
  # it's wrong already
end

Given /^outputs are correct/ do
  FileUtils.cp(Dir.glob("#{Clicoder::OUTPUTS_DIRNAME}/*.txt"), Clicoder::MY_OUTPUTS_DIRNAME)
end

Then /^an executable should be generated/ do
  expect(File.exists?('a.out')).to be_true
end

Then /^my answer should be output in my outputs directory/ do
  Dir.glob("#{Clicoder::INPUTS_DIRNAME}/*.txt") do |file|
    basename = File.basename(file)
    expect(File.exists?("#{Clicoder::MY_OUTPUTS_DIRNAME}/#{basename}")).to be_true
  end
end

