require 'clicoder'
require 'clicoder/sites/sample_site'
require 'launchy'

Given /^SampleSite submission url is stubbed with webmock/ do
  stub_request(:post, "http://samplesite.com/submit").
    with(:body => {"password"=>"sample_password", "user_id"=>"sample_user_id"},
         :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'Host'=>'samplesite.com', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => "Success", :headers => {})
  stub_request(:post, "http://samplesite.com/submit").
    with(:body => {"password"=>"", "user_id"=>""},
         :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'Host'=>'samplesite.com', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => "Failure", :headers => {})
end

Given /^I don't have user_id and password/ do
  FileUtils.rm("#{ENV['HOME']}/.clicoder.d/config.yml")
end

Given /^in a problem directory/ do
  sample_site = Clicoder::SampleSite.new
  sample_site.start
  Dir.chdir(sample_site.working_directory)
end

Given /^there is no output/ do
  FileUtils.rm(Dir.glob("#{Clicoder::MY_OUTPUTS_DIRNAME}/*.txt"))
end

Given /^outputs are wrong/ do
  # it's wrong already
end

Given /^outputs are correct/ do
  FileUtils.cp(Dir.glob("#{Clicoder::OUTPUTS_DIRNAME}/*.txt"), Clicoder::MY_OUTPUTS_DIRNAME)
end

Given /^the answer differs in second decimal place/ do
  FileUtils.rm(Dir.glob("#{Clicoder::OUTPUTS_DIRNAME}/*"))
  FileUtils.rm(Dir.glob("#{Clicoder::MY_OUTPUTS_DIRNAME}/*"))
  File.open("#{Clicoder::OUTPUTS_DIRNAME}/0.txt", 'w') do |f|
    f.write(<<-EOS)
    0.11 0.11
    0.13 0.13
    EOS
  end
  File.open("#{Clicoder::MY_OUTPUTS_DIRNAME}/0.txt", 'w') do |f|
    f.write(<<-EOS)
    0.12 0.12
    0.12 0.12
    EOS
  end
end

Given /^Launchy.open is stubbed/ do
  @launchy_open_count = 0
  Launchy.stub(:open) do |url|
    @launchy_open_count += 1
    puts "opening #{url}"
  end
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

Then /^the submission status should be opened/ do
  @launchy_open_count.should eq(1)
end

Then /^the problem page should be opened/ do
  @launchy_open_count.should eq(1)
end
