require "open-uri"
require "nokogiri"
require "yaml"
require "net/http"
require "abstract_method"
require "reverse_markdown"

require "clicoder"
require "clicoder/config"

module Clicoder
  class SiteBase
    include Helper

    # Parameters
    abstract_method :site_name
    abstract_method :problem_url
    abstract_method :working_directory

    # Operations
    abstract_method :login
    abstract_method :submit
    abstract_method :open_submission

    def self.new_with_config(config)
      case config["site"]
      when "sample_site"
        SampleSite.new
      when "aoj"
        AOJ.new(config["problem_number"])
      when "atcoder"
        AtCoder.new(config["contest_id"], config["task_id"])
      end
    end

    def start
      prepare_directories
      login do
        download_description
        download_inputs
        download_outputs
      end
      copy_template
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

    def download_description
      Dir.chdir(working_directory) do
        File.open("description.md", "w") do |f|
          f.write(ReverseMarkdown.parse(fetch_description))
        end
      end
    end

    def download_inputs
      Dir.chdir("#{working_directory}/#{INPUTS_DIRNAME}") do
        fetch_inputs.each_with_index do |input, i|
          File.open("#{i}", "w") do |f|
            f.write(sanitize(input) + "\n")
          end
        end
      end
    end

    def download_outputs
      Dir.chdir("#{working_directory}/#{OUTPUTS_DIRNAME}") do
        fetch_outputs.each_with_index do |output, i|
          File.open("#{i}", "w") do |f|
            f.write(sanitize(output) + "\n")
          end
        end
      end
    end

    def copy_template
      template_file = config.asset("template")
      return unless File.file?(template_file)
      ext = File.extname(template_file)
      FileUtils.cp(template_file, "#{working_directory}/main#{ext}")
    end

    def fetch_description
      xml_document.at_xpath(description_xpath)
    end

    def fetch_inputs
      input_nodes = xml_document.xpath(inputs_xpath)
      input_nodes.map(&:text)
    end

    def fetch_outputs
      outputs_nodes = xml_document.xpath(outputs_xpath)
      outputs_nodes.map(&:text)
    end

    def description_xpath
      config.get("xpaths", site_name, "description")
    end

    def inputs_xpath
      config.get("xpaths", site_name, "inputs").join('|')
    end

    def outputs_xpath
      config.get("xpaths", site_name, "outputs").join('|')
    end

    def store_local_config
      config.local["site"] = site_name
      File.open("#{working_directory}/.config.yml", "w") do |f|
        f.write(config.local.to_yaml)
      end
    end

    def xml_document
      login do |mechanize, _contest_page|
        @xml_document ||= Nokogiri::HTML(mechanize.get(problem_url).content)
      end
    end

    def config
      @config ||= Config.new
    end

    private

    def sanitize(text)
      text.strip.tr("\r", "")
    end
  end
end
