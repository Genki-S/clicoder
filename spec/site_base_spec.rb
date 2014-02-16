require 'spec_helper'

require 'clicoder/site_base'
require 'clicoder/config'

require 'nokogiri'
require 'abstract_method'

module Clicoder
  describe SiteBase do
    let(:site_base) { SiteBase.new }
    let(:config) { Config.new }

    let(:abstract_methods) do
      %i(
        site_name
        problem_url
        inputs_xpath
        outputs_xpath
        working_directory

        submit
      )
    end

    it 'raises AbstractMethodCalled for abstract methods' do
      abstract_methods.each do |method|
        expect{ site_base.send(method) }.to raise_exception(AbstractMethodCalled)
      end
    end

    describe '#config' do
      it 'returns config object' do
        expect(site_base.config).to be_a Config
      end
    end

    context 'when all abstract methods are stubbed' do
      before do
        site_base.stub(:site_name).and_return('sample_site')
        site_base.stub(:problem_url).and_return("#{FIXTURE_DIR}/sample_problem.html")
        site_base.stub(:inputs_xpath).and_return('//div[@id="inputs"]/pre')
        site_base.stub(:outputs_xpath).and_return('//div[@id="outputs"]/pre')
        site_base.stub(:working_directory).and_return('working_directory')
      end

      describe '#start' do
        before do
          config.local['site'] = site_base.site_name
          site_base.start
        end

        it 'creates working directory specified by #working_directory' do
          expect(File.directory?(site_base.working_directory)).to be_true
        end

        it 'prepares directories for inputs, outpus, and myoutputs' do
          dirs = [INPUTS_DIRNAME, OUTPUTS_DIRNAME, MY_OUTPUTS_DIRNAME]
          Dir.chdir(site_base.working_directory) do
            dirs.each do |dir|
              expect(File.directory?(dir)).to be_true
            end
          end
        end

        it 'stores sample input files named by number.txt' do
          input_strings = site_base.fetch_inputs
          inputs_dir = "#{site_base.working_directory}/inputs"
          Dir.chdir(inputs_dir) do
            input_strings.each_with_index do |input, i|
              expect(File.read("#{i}.txt")).to eql(input)
            end
          end
        end

        it 'stores output for sample input files named by number.txt' do
          output_strings = site_base.fetch_outputs
          outputs_dir = "#{site_base.working_directory}/outputs"
          Dir.chdir(outputs_dir) do
            output_strings.each_with_index do |output, i|
              expect(File.read("#{i}.txt")).to eql(output)
            end
          end
        end

        it 'copies template file specified by config into problem directory named main.ext' do
          template = File.expand_path(config.template, config.global_config_dir)
          ext = File.extname(template)
          Dir.chdir(site_base.working_directory) do
            expect(File.read("main#{ext}")).to eql(File.read(template))
          end
        end

        it 'copies Makefile specified by config into problem directory' do
          makefile = File.expand_path(config.makefile, config.global_config_dir)
          Dir.chdir(site_base.working_directory) do
            expect(File.read('Makefile')).to eql(File.read(makefile))
          end
        end

        it 'stores local configuration' do
          Dir.chdir(site_base.working_directory) do
            expect(YAML::load_file('.config.yml')).to eql(config.local)
          end
        end

        context 'when config is not present', config: :absent do
          it 'does not raise error' do
            expect{ site_base.start }.to_not raise_error
          end
        end
      end

      describe '#ext_to_language_name' do
        it 'returns "C++" for ".cpp" extension' do
          expect(site_base.ext_to_language_name('cpp')).to eql('C++')
          expect(site_base.ext_to_language_name('.cpp')).to eql('C++')
        end

        it 'returns "Ruby" for ".rb" extension' do
          expect(site_base.ext_to_language_name('rb')).to eql('Ruby')
          expect(site_base.ext_to_language_name('.rb')).to eql('Ruby')
        end
      end

      describe '#fetch_inputs' do
        it 'downloads sample inputs from problem page' do
          input_nodes = Nokogiri::HTML(open(site_base.problem_url)).xpath(site_base.inputs_xpath)
          inputs = input_nodes.map{ |node| node.text.strip }
          expect(site_base.fetch_inputs).to eql(inputs)
        end
      end

      describe '#fetch_outputs' do
        it 'downloads outputs for sample inputs from problem page' do
          output_nodes = Nokogiri::HTML(open(site_base.problem_url)).xpath(site_base.outputs_xpath)
          outputs = output_nodes.map{ |node| node.text.strip }
          expect(site_base.fetch_outputs).to eql(outputs)
        end
      end
    end
  end
end
