require 'clicoder/aoj'

require 'tmpdir'

module Clicoder
  describe AOJ do
    let(:aoj) { AOJ.new(problem_number) }
    let(:problem_number) { 1 }
    let(:problem_id) { "%04d" % problem_number }

    around(:each) do |example|
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          example.run
        end
      end
    end

    describe '#start' do
      it 'creates new directory named by problem_id' do
        expect(File.directory?(problem_id)).to be_false
        aoj.start
        expect(File.directory?(problem_id)).to be_true
      end

      it 'prepares directories for inputs, outpus, and myoutputs' do
        dirs = ['inputs', 'outputs', 'myoutputs']
        aoj.start
        Dir.chdir(problem_id) do
          dirs.each do |d|
            expect(File.directory?(d)).to be_true
          end
        end
      end
    end

    describe '#get_url' do
      it 'returns url with problem number' do
        expect(aoj.get_url).to eql("http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=#{problem_id}")
      end
    end
  end
end
