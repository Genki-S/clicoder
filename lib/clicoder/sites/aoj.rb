require 'clicoder/site_base'
require 'clicoder/config'

module Clicoder
  class AOJ < SiteBase

    def initialize(problem_number)
      @problem_id = "%04d" % problem_number
      @aoj_config = Hash.new { '' }
      @aoj_config.merge!(config.global['aoj']) if config.global.has_key?('aoj')
    end

    def submit
      submit_url = 'http://judge.u-aizu.ac.jp/onlinejudge/servlet/Submit'
      post_params = {
        userID: @aoj_config['user_id'],
        password: @aoj_config['password'],
        problemNO: @problem_id,
        language: ext_to_language_name(File.extname(detect_main)),
        sourceCode: File.read(detect_main),
        submit: 'Send'
      }
      response = Net::HTTP.post_form(URI(submit_url), post_params)
      return response.body !~ /UserID or Password is Wrong/
    end

    def site_name
      'aoj'
    end

    def problem_url
      "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=#{@problem_id}"
    end

    def inputs_xpath
      '//pre[preceding-sibling::h2[1][text()="Sample Input"]]'
    end

    def outputs_xpath
      '//pre[preceding-sibling::h2[1][text()="Output for the Sample Input"]]'
    end

    def working_directory
      @problem_id
    end

  end
end
