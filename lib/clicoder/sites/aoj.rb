require "clicoder/site_base"
require "clicoder/config"

require "mechanize"

module Clicoder
  class AOJ < SiteBase
    def initialize(problem_number)
      config.local["problem_number"] = problem_number
      @problem_id = "%04d" % problem_number
    end

    def submit
      submit_url = "http://judge.u-aizu.ac.jp/onlinejudge/servlet/Submit"
      post_params = {
        userID: config.get("sites", "aoj", "user_id"),
        password: config.get("sites", "aoj", "password"),
        problemNO: @problem_id,
        language: ext_to_language_name(File.extname(detect_main)),
        sourceCode: File.read(detect_main),
        submit: "Send"
      }
      response = Net::HTTP.post_form(URI(submit_url), post_params)
      response.body !~ /UserID or Password is Wrong/
    end

    def open_submission
      Launchy.open("http://judge.u-aizu.ac.jp/onlinejudge/status.jsp")
    end

    def login
      # no need to login for now
      Mechanize.start do |m|
        yield m
      end
    end

    def site_name
      "aoj"
    end

    def problem_url
      "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=#{@problem_id}"
    end

    def working_directory
      @problem_id
    end
  end
end
