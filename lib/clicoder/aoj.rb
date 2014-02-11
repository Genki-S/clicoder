require 'open-uri'
require 'nokogiri'
require 'yaml'

module Clicoder
  class AOJ
    @@url_format = 'http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id={{problem_id}}'
    @@inputs_dir = 'inputs'
    @@outputs_dir = 'outputs'
    @@myoutputs_dir = 'myoutputs'

    def initialize(problem_number)
      @problem_id = "%04d" % problem_number
      if File.exists?('config.yml')
        @config = YAML::load_file('config.yml')
      else
        @config = {}
      end
    end

    def start
      prepare_directories
      download_inputs
      download_outputs
      copy_template
    end

    def prepare_directories
      FileUtils.mkdir_p(@problem_id)
      Dir.chdir(@problem_id) do
        FileUtils.mkdir_p(@@inputs_dir)
        FileUtils.mkdir_p(@@outputs_dir)
        FileUtils.mkdir_p(@@myoutputs_dir)
      end
    end

    def download_inputs
      Dir.chdir("#{@problem_id}/#{@@inputs_dir}") do
        fetch_inputs.each_with_index do |input, i|
          File.open("#{i}.txt", 'w') do |f|
            f.write(input)
          end
        end
      end
    end

    def download_outputs
      Dir.chdir("#{@problem_id}/#{@@outputs_dir}") do
        fetch_outputs.each_with_index do |output, i|
          File.open("#{i}.txt", 'w') do |f|
            f.write(output)
          end
        end
      end
    end

    def copy_template
      return unless @config[:template] && File.exists?(@config[:template])
      ext = File.extname(@config[:template])
      FileUtils.cp(@config[:template], "#{@problem_id}/main#{ext}")
    end

    def fetch_inputs
      pre = xml_document.xpath('//pre[preceding-sibling::h2[1][text()="Sample Input"]]')
      pre.map { |node| node.text.lstrip }
    end

    def fetch_outputs
      pre = xml_document.xpath('//pre[preceding-sibling::h2[1][text()="Output for the Sample Input"]]')
      pre.map { |node| node.text.lstrip }
    end

    def get_url
      @@url_format.gsub('{{problem_id}}', "%04d" % @problem_id)
    end

    def user_id
      @config[:user_id]
    end

    def work_dir
      @problem_id
    end

    private

    def xml_document
      @xml_document ||= Nokogiri::HTML(open(get_url))
    end
  end
end
