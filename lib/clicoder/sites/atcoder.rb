require 'clicoder/site_base'
require 'clicoder/config'

module Clicoder
  class AtCoder < SiteBase

    def initialize(contest_id, problem_number)
      config.local['contest_id'] = contest_id
      config.local['problem_number'] = problem_number
      @contest_id = contest_id
      @problem_id = "#{@contest_id}_#{problem_number}"
    end

    def submit
    end

    def open_submission
    end

    def site_name
      'atcoder'
    end

    def problem_url
      "http://#{@contest_id}.contest.atcoder.jp/tasks/#{@problem_id}"
    end

    def description_xpath
      '//div[@id="task-statement"]'
    end

    def inputs_xpath
      '//pre[preceding-sibling::h3[1][contains(text(), "入力例")]]'
    end

    def outputs_xpath
      '//pre[preceding-sibling::h3[1][contains(text(), "出力例")]]'
    end

    def working_directory
      @problem_id
    end
  end
end
