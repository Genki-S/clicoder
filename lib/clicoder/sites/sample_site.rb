require 'clicoder/site_base'
require 'clicoder/config'

module Clicoder
  class SampleSite < SiteBase

    def submit
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
