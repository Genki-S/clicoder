require "clicoder/site_base"
require "clicoder/config"

require "mechanize"

module Clicoder
  class AtCoder < SiteBase

    # Order by priority
    LANGUAGE_NAMES_BY_EXT = {
      'cpp'  => [/C++ (GCC 4.9.2)/, /C++/],
      'c'    => [/C (GCC 4.9.2)/],
      'py'   => [/Python (2.7.3)/, /Python/],
      'pl'   => [/Perl (5.14.2)/, /Perl/],
      'rb'   => [/Ruby (2.1.5p273)/, /Ruby (1.9.3p550)/, /Ruby (1.9.3)/, /Ruby/],
    }

    def initialize(contest_id, task_id)
      config.local["contest_id"] = contest_id
      config.local["task_id"] = task_id
      @contest_id = contest_id
      @task_id = task_id
    end

    def submit
      login do |mechanize, _contest_page|
        problem_page = mechanize.get(problem_url)
        submit_page = problem_page.link_with(href: /submit\?task_id/).click
        submit_page.form_with(action: /submit/) do |f|
          task_id = f.field_with(name: 'task_id').value
          language_names = LANGUAGE_NAMES_BY_EXT[File.extname(detect_main).tr('.', '')]
          options = f.field_with(name: "language_id_#{task_id}").options
          found = false
          language_names.each do |lang|
            options.each do |opt|
              if opt.text =~ lang
                opt.select
                found = true
                break
              end
            end
            break if found
          end
          raise 'Language option did not found' unless found
          f.field_with(name: "source_code").value = File.read(detect_main)
        end.click_button
      end
    end

    def open_submission
      Launchy.open("http://#{@contest_id}.contest.atcoder.jp/submissions/me")
    end

    def login
      Mechanize.start do |m|
        login_page = m.get("http://#{@contest_id}.contest.atcoder.jp/login")
        contest_home_page = login_page.form_with(action: "/login") do |f|
          f.field_with(name: "name").value = config.get("sites", "atcoder", "user_id")
          f.field_with(name: "password").value = config.get("sites", "atcoder", "password")
        end.click_button

        yield m, contest_home_page
      end
    end

    def site_name
      "atcoder"
    end

    def problem_url
      "http://#{@contest_id}.contest.atcoder.jp/tasks/#{@task_id}"
    end

    def working_directory
      @task_id
    end
  end
end
