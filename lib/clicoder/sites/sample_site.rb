require 'clicoder/site_base'
require 'clicoder/config'

require 'net/http'

module Clicoder
  class SampleSite < SiteBase

    def submit
      submit_url = 'http://samplesite.com/submit'
      sample_site_config = Hash.new { '' }
      sample_site_config.merge!(config.global['sample_site']) if config.global.has_key?('sample_site')
      post_params = {
        user_id: sample_site_config['user_id'],
        password: sample_site_config['password'],
      }
      response = Net::HTTP.post_form(URI(submit_url), post_params)
      return response.body =~ /Success/
    end

    def site_name
      'sample_site'
    end

    def problem_url
      "#{GEM_ROOT}/fixtures/sample_problem.html"
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
