require 'spec_helper'

require 'clicoder'
require 'clicoder/aoj'
require 'clicoder/config'

require 'open-uri'
require 'nokogiri'
require 'yaml'

module Clicoder
  describe AOJ do

    # Always return new instance to resemble CLI execution
    def aoj
      AOJ.new(problem_number)
    end

    let(:problem_number) { 1 }
    let(:problem_id) { "%04d" % problem_number }
    let(:problem_url) { "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=#{problem_id}" }
    let(:xml_document) { Nokogiri::HTML(open(problem_url)) }
    let(:config) { Config.new }

    shared_context 'when config is not present', config: :absent do
      before do
        Config.any_instance.stub(:global).and_return({})
        Config.any_instance.stub(:local).and_return({})
      end
    end

    shared_context 'in a problem directory', cwd: :problem do
      around(:each) do |example|
        aoj.start
        Dir.chdir(aoj.work_dir) do
          example.run
        end
      end
    end

    describe '.new' do
      it 'loads configuration from config file' do
        expect(aoj.user_id).to eql(config.global['aoj']['user_id'])
      end

      context 'when there is no config file', config: :absent do
        it 'does not raise error and continue without configuration' do
          expect(aoj.user_id).to eql('')
        end
      end
    end

    describe '#start' do
      context 'when config is present' do
        before(:each) do
          aoj.start
        end

        it 'creates new directory named by problem_id' do
          expect(File.directory?(problem_id)).to be_true
        end

        it 'prepares directories for inputs, outpus, and myoutputs' do
          dirs = [INPUTS_DIRNAME, OUTPUTS_DIRNAME, MY_OUTPUTS_DIRNAME]
          Dir.chdir(aoj.work_dir) do
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

        it 'copies template file specified by config file into problem directory named main.ext' do
          template = File.expand_path(config.global['aoj']['template'], config.global_config_dir)
          ext = File.extname(template)
          Dir.chdir(aoj.work_dir) do
            expect(File.read("main#{ext}")).to eql(File.read(template))
          end
        end

        it 'copies Makefile specified by config file into problem directory' do
          makefile = File.expand_path(config.global['aoj']['makefile'], config.global_config_dir)
          Dir.chdir(aoj.work_dir) do
            expect(File.read('Makefile')).to eql(File.read(makefile))
          end
        end
      end

      context 'when config is not present', config: :absent do
        it 'does not raise error' do
          expect{ aoj.start }.to_not raise_error
        end
      end
    end

    describe '#submit', cwd: :problem do
      context 'when user ID and password is present' do
        it 'returns true' do
          expect(aoj.submit).to be_true
        end
      end

      context 'when user ID and password is not present', config: :absent do
        it 'returns false' do
          expect(aoj.submit).to be_false
        end
      end
    end

    describe '#ext_to_language_name' do
      it 'returns "C++" for ".cpp" extension' do
        expect(aoj.ext_to_language_name('cpp')).to eql('C++')
        expect(aoj.ext_to_language_name('.cpp')).to eql('C++')
      end

      it 'returns "Ruby" for ".rb" extension' do
        expect(aoj.ext_to_language_name('rb')).to eql('Ruby')
        expect(aoj.ext_to_language_name('.rb')).to eql('Ruby')
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
