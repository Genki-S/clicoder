require 'spec_helper'

require 'clicoder/config'
require 'clicoder/sites/sample_site'

require 'reverse_markdown'

module Clicoder
  describe SampleSite do
    let(:sample_site) { SampleSite.new }
    let(:config) { sample_site.config }

    describe '#start' do
      before do
        sample_site.start
      end

      it 'creates working directory specified by #working_directory' do
        expect(File.directory?(sample_site.working_directory)).to be_true
      end

      it 'prepares directories for inputs, outpus, and myoutputs' do
        dirs = [INPUTS_DIRNAME, OUTPUTS_DIRNAME, MY_OUTPUTS_DIRNAME]
        Dir.chdir(sample_site.working_directory) do
          dirs.each do |dir|
            expect(File.directory?(dir)).to be_true
          end
        end
      end

      it 'stores description as markdown' do
        description = sample_site.fetch_description
        Dir.chdir(sample_site.working_directory) do
          expect(File.read('description.md')).to eql(ReverseMarkdown.parse(description))
        end
      end

      it 'stores sample input files named by number.txt with a newline at the end' do
        input_strings = sample_site.fetch_inputs
        inputs_dir = "#{sample_site.working_directory}/inputs"
        Dir.chdir(inputs_dir) do
          input_strings.each_with_index do |input, i|
            expect(File.read("#{i}.txt")).to eql(input.strip + "\n")
          end
        end
      end

      it 'stores output for sample input files named by number.txt with a newline at the end' do
        output_strings = sample_site.fetch_outputs
        outputs_dir = "#{sample_site.working_directory}/outputs"
        Dir.chdir(outputs_dir) do
          output_strings.each_with_index do |output, i|
            expect(File.read("#{i}.txt")).to eql(output.strip + "\n")
          end
        end
      end

      it 'copies template file specified by config into problem directory named main.ext' do
        template = File.expand_path(config.asset('template'), config.global_config_dir)
        ext = File.extname(template)
        Dir.chdir(sample_site.working_directory) do
          expect(File.read("main#{ext}")).to eql(File.read(template))
        end
      end

      it 'copies Makefile specified by config into problem directory' do
        makefile = File.expand_path(config.asset('makefile'), config.global_config_dir)
        Dir.chdir(sample_site.working_directory) do
          expect(File.read('Makefile')).to eql(File.read(makefile))
        end
      end

      it 'stores site name to local configuration' do
        expect(config.local['site']).to eql(sample_site.site_name)
      end

      it 'stores local configuration as a yaml file' do
        Dir.chdir(sample_site.working_directory) do
          expect(YAML::load_file('.config.yml')).to eql(config.local)
        end
      end

      context 'when config is not present' do
        before do
          Config.any_instance.stub(:global).and_return({})
          Config.any_instance.stub(:local).and_return({})
        end

        it 'does not raise error' do
          expect{ sample_site.start }.to_not raise_error
        end
      end
    end

    describe '#fetch_inputs' do
      it 'downloads sample inputs from problem page' do
        input_nodes = Nokogiri::HTML(open(sample_site.problem_url)).xpath(sample_site.inputs_xpath)
        inputs = input_nodes.map(&:text)
        expect(sample_site.fetch_inputs).to eql(inputs)
      end
    end

    describe '#fetch_outputs' do
      it 'downloads outputs for sample inputs from problem page' do
        output_nodes = Nokogiri::HTML(open(sample_site.problem_url)).xpath(sample_site.outputs_xpath)
        outputs = output_nodes.map{ |node| node.text.strip }
        expect(sample_site.fetch_outputs).to eql(outputs)
      end
    end

    describe '#login' do
      it 'yields control with no args' do
        expect { |b| sample_site.login(&b) }.to yield_with_no_args
      end
    end
  end
end
