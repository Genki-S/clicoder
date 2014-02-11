require 'clicoder'
require 'clicoder/aoj'

require 'tmpdir'
require 'open-uri'
require 'nokogiri'
require 'yaml'

module Clicoder
  describe AOJ do
    let(:aoj) { AOJ.new(problem_number) }
    let(:problem_number) { 1 }
    let(:problem_id) { "%04d" % problem_number }
    let(:problem_url) { "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=#{problem_id}" }
    let(:xml_document) { Nokogiri::HTML(open(problem_url)) }
    let(:config) {
      {
        user_id: 'Glen_S',
        password: '',
        template: 'template.cpp',
      }
    }

    around(:each) do |example|
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          File.open('config.yml', 'w') { |f| f.write(config.to_yaml) }
          File.open(config[:template], 'w') { |f| f.write('template contents') }
          example.run
        end
      end
    end

    describe '.new' do
      it 'loads configuration from config.yml file' do
        expect(aoj.user_id).to eql(config[:user_id])
      end

      context 'when there is no config.yml file' do
        before(:each) do
          FileUtils.rm('config.yml')
        end

        it 'does not raise error and continue without configuration' do
          expect(aoj.user_id).to be_nil
        end
      end
    end

    describe '#start' do
      context 'when config.yml is present' do
        before(:each) do
          aoj.start
        end

        it 'creates new directory named by problem_id' do
          expect(File.directory?(problem_id)).to be_true
        end

        it 'prepares directories for inputs, outpus, and myoutputs' do
          dirs = [INPUTS_DIRNAME, OUTPUTS_DIRNAME, MY_OUTPUTS_DIRNAME]
          Dir.chdir(problem_id) do
            dirs.each do |d|
              expect(File.directory?(d)).to be_true
            end
          end
        end

        it 'stores sample input files into "inputs" directory named by number.txt' do
          input_strings = aoj.fetch_inputs
          inputs_dir = "#{problem_id}/inputs"
          Dir.chdir(inputs_dir) do
            input_strings.each_with_index do |input, i|
              expect(File.read("#{i}.txt")).to eql(input)
            end
          end
        end

        it 'stores output for sample input files into "outputs" directory named by number.txt' do
          output_strings = aoj.fetch_outputs
          outputs_dir = "#{problem_id}/outputs"
          Dir.chdir(outputs_dir) do
            output_strings.each_with_index do |output, i|
              expect(File.read("#{i}.txt")).to eql(output)
            end
          end
        end

        it 'copies template file specified by config.yml into problem directory named main.ext' do
          template = File.expand_path(config[:template], Dir.pwd)
          ext = File.extname(template)
          Dir.chdir(problem_id) do
            expect(File.read("main#{ext}")).to eql(File.read(template))
          end
        end
      end

      context 'when config.yml is not present' do
        before(:each) do
          FileUtils.rm('config.yml')
        end

        it 'does not raise error trying to copy template file' do
          expect{ aoj.start }.to_not raise_error
        end
      end
    end

    describe '#fetch_inputs' do
      it 'downloads sample inputs from problem page' do
        pre = xml_document.xpath('//pre[preceding-sibling::h2[1][text()="Sample Input"]]')
        inputs = pre.map { |node| node.text.lstrip }
        expect(aoj.fetch_inputs).to eql(inputs)
      end
    end

    describe '#fetch_outputs' do
      it 'downloads outputs for sample inputs from problem page' do
        pre = xml_document.xpath('//pre[preceding-sibling::h2[1][text()="Output for the Sample Input"]]')
        outputs = pre.map { |node| node.text.lstrip }
        expect(aoj.fetch_outputs).to eql(outputs)
      end
    end

    describe '#get_url' do
      it 'returns url with problem number' do
        expect(aoj.get_url).to eql(problem_url)
      end
    end
  end
end
