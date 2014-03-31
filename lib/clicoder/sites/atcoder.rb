require 'clicoder/site_base'
require 'clicoder/config'

require 'mechanize'

module Clicoder
  class AtCoder < SiteBase

    def initialize(contest_id, problem_number)
      config.local['contest_id'] = contest_id
      config.local['problem_number'] = problem_number
      @contest_id = contest_id
      @problem_id = "#{@contest_id}_#{problem_number}"
    end

    def submit
      login do |mechanize, contest_page|
        problem_page = mechanize.get(problem_url)
        submit_page = problem_page.link_with(href: /submit/).click
        submit_page.form_with(action: /submit/) do |f|
          f.field_with(name: 'source_code').value = File.read(detect_main)
        end.click_button
      end
    end

    def open_submission
      Launchy.open("http://#{@contest_id}.contest.atcoder.jp/submissions/me")
    end

    def login
      Mechanize.start do |m|
        login_page = m.get("http://#{@contest_id}.contest.atcoder.jp/login")
        contest_home_page = login_page.form_with(action: '/login') do |f|
          f.field_with(name: 'name').value = config.get('atcoder', 'user_id')
          f.field_with(name: 'password').value = config.get('atcoder', 'password')
        end.click_button

        yield m, contest_home_page
      end
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
