require 'open-uri'
require 'nokogiri'
require 'yaml'
require 'net/http'
require 'abstract_method'

require 'clicoder'
require 'clicoder/config'

module Clicoder
  class SiteBase
    include Helper

    # Parameters
    abstract_method :site_name
    abstract_method :problem_url
    abstract_method :inputs_xpath
    abstract_method :outputs_xpath
    abstract_method :working_directory

    # Operations
    abstract_method :submit

    def start
      prepare_directories
      download_inputs
      download_outputs
      copy_template
      copy_makefile
      store_local_config
    end

    def prepare_directories
      FileUtils.mkdir_p(working_directory)
      Dir.chdir(working_directory) do
        FileUtils.mkdir_p(INPUTS_DIRNAME)
        FileUtils.mkdir_p(OUTPUTS_DIRNAME)
        FileUtils.mkdir_p(MY_OUTPUTS_DIRNAME)
      end
    end

    def download_inputs
      Dir.chdir("#{working_directory}/#{INPUTS_DIRNAME}") do
        fetch_inputs.each_with_index do |input, i|
          File.open("#{i}.txt", 'w') do |f|
            f.write(input)
          end
        end
      end
    end

    def download_outputs
      Dir.chdir("#{working_directory}/#{OUTPUTS_DIRNAME}") do
        fetch_outputs.each_with_index do |output, i|
          File.open("#{i}.txt", 'w') do |f|
            f.write(output)
          end
        end
      end
    end

    def copy_template
      template_file = config.asset('template')
      return unless File.file?(template_file)
      ext = File.extname(template_file)
      FileUtils.cp(template_file, "#{working_directory}/main#{ext}")
    end

    def copy_makefile
      makefile = config.asset('makefile')
      return unless File.file?(makefile)
      ext = File.extname(makefile)
      FileUtils.cp(makefile, "#{working_directory}/Makefile")
    end

    def fetch_inputs
      input_nodes = xml_document.xpath(inputs_xpath)
      input_nodes.map { |node| node.text.strip }
    end

    def fetch_outputs
      outputs_nodes = xml_document.xpath(outputs_xpath)
      outputs_nodes.map { |node| node.text.strip }
    end

    def store_local_config
      config.local['site'] = site_name
      File.open("#{working_directory}/.config.yml", 'w') do |f|
        f.write(config.local.to_yaml)
      end
    end

    def xml_document
      @xml_document ||= Nokogiri::HTML(open(problem_url))
    end

    def config
      @config ||= Config.new
    end
  end
end
