require 'spec_helper'
require 'clicoder/sites/aoj'

module Clicoder
  describe AOJ do
    let(:aoj) { AOJ.new(problem_number) }
    let(:problem_number) { 1 }
    let(:problem_id) { '0001' }

    # Use around hook to execute stub_request before other around hooks
    around(:each) do |example|
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

    describe '#working_directory' do
      it 'returns problem id' do
        expect(aoj.working_directory).to eql(problem_id)
      end
    end

    describe '#submit' do
      context 'when config is present' do
        before do
          config = {
            'aoj' => {
              'user_id' => 'Glen_S',
              'password' => 'pass',
            }
          }
          Config.stub(:global).and_return(config)
        end

        it 'returns true' do
          expect(aoj.submit).to be_true
        end
      end

      context 'when config is absent' do
        before do
          Config.stub(:global).and_return({})
        end

        it 'returns false' do
          expect(aoj.submit).to be_false
        end
      end
    end
  end
end
