require 'open-uri'
require 'nokogiri'

module Clicoder
  class AOJ
    @@url_format = 'http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id={{problem_id}}'
    @@inputs_dir = 'inputs'
    @@outputs_dir = 'outputs'
    @@myoutputs_dir = 'myoutputs'

    def initialize(problem_number)
      @problem_id = "%04d" % problem_number
    end

    def start
      prepare_directories
      download_inputs
    end

    def prepare_directories
      Dir.mkdir(@problem_id)
      Dir.chdir(@problem_id) do
        Dir.mkdir(@@inputs_dir)
        Dir.mkdir(@@outputs_dir)
        Dir.mkdir(@@myoutputs_dir)
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

    private

    def xml_document
      @xml_document ||= Nokogiri::HTML(open(get_url))
    end
  end
end
