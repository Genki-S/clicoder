require 'clicoder/site_base'
require 'clicoder/config'

require 'net/http'
require 'launchy'

module Clicoder
  class SampleSite < SiteBase

    def submit
      submit_url = 'http://samplesite.com/submit'
      post_params = {
        user_id: config.get('sample_site', 'user_id'),
        password: config.get('sample_site', 'password'),
      }
      response = Net::HTTP.post_form(URI(submit_url), post_params)
      return response.body =~ /Success/
    end

    def open_submission
      Launchy.open('http://samplesite.com/submissions')
    end

    def login
      yield
    end

    def site_name
      'sample_site'
    end

    def problem_url
      "#{GEM_ROOT}/fixtures/sample_problem.html"
    end

    def description_xpath
      '//div[@id="description"]'
    end

    def inputs_xpath
      '//div[@id="inputs"]/pre'
    end

    def outputs_xpath
      '//div[@id="outputs"]/pre'
    end

    def working_directory
      'working_directory'
    end
  end
end
