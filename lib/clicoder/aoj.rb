require 'open-uri'
require 'nokogiri'
require 'yaml'
require 'net/http'

require 'clicoder'
require 'clicoder/config'

module Clicoder
  class AOJ
    @@url_format = 'http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id={{problem_id}}'

    def initialize(problem_number)
      @problem_id = "%04d" % problem_number
      @submit_url = 'http://judge.u-aizu.ac.jp/onlinejudge/servlet/Submit'
      @config = Config.new
      @aoj_config = @config.global.has_key?('aoj') ? @config.global['aoj'] : Hash.new { '' }
    end

    def start
      prepare_directories
      download_inputs
      download_outputs
      copy_template
      copy_makefile

      # Store local config
      local_config = { site: 'aoj' }
      File.open("#{work_dir}/.config.yml", 'w') { |f| f.write(local_config.to_yaml) }
    end

    def submit
      post_params = {
        userID: user_id,
        password: @aoj_config['password'],
        problemNO: @problem_id,
        language: ext_to_language_name(File.extname(main_program)),
        sourceCode: File.read(main_program),
        submit: 'Send'
      }
      response = Net::HTTP.post_form(URI(@submit_url), post_params)
      return response.body !~ /UserID or Password is Wrong/
    end

    def prepare_directories
      FileUtils.mkdir_p(@problem_id)
      Dir.chdir(work_dir) do
        FileUtils.mkdir_p(INPUTS_DIRNAME)
        FileUtils.mkdir_p(OUTPUTS_DIRNAME)
        FileUtils.mkdir_p(MY_OUTPUTS_DIRNAME)
      end
    end

    def download_inputs
      Dir.chdir("#{work_dir}/#{INPUTS_DIRNAME}") do
        fetch_inputs.each_with_index do |input, i|
          File.open("#{i}.txt", 'w') do |f|
            f.write(input)
          end
        end
      end
    end

    def download_outputs
      Dir.chdir("#{work_dir}/#{OUTPUTS_DIRNAME}") do
        fetch_outputs.each_with_index do |output, i|
          File.open("#{i}.txt", 'w') do |f|
            f.write(output)
          end
        end
      end
    end

    def copy_template
      template_file = File.expand_path(@aoj_config['template'], @config.global_config_dir)
      return unless File.file?(template_file)
      ext = File.extname(template_file)
      FileUtils.cp(template_file, "#{@problem_id}/main#{ext}")
    end

    def copy_makefile
      makefile = File.expand_path(@aoj_config['makefile'], @config.global_config_dir)
      return unless File.file?(makefile)
      ext = File.extname(makefile)
      FileUtils.cp(makefile, "#{@problem_id}/Makefile")
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
      @aoj_config['user_id']
    end

    def work_dir
      @problem_id
    end

    def ext_to_language_name(ext)
      map = {
        cpp: 'C++',
        cc: 'C++',
        c: 'C',
        java: 'JAVA',
        cs: 'C#',
        d: 'D',
        rb: 'Ruby',
        py: 'Python',
        php: 'PHP'
      }
      return map[ext.gsub(/^\./, '').to_sym]
    end

    def main_program
      Dir.glob('main.*').first
    end

    private

    def xml_document
      @xml_document ||= Nokogiri::HTML(open(get_url))
    end
  end
end
