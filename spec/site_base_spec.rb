require "spec_helper"

require "clicoder/site_base"
require "clicoder/config"

require "nokogiri"
require "abstract_method"

module Clicoder
  describe SiteBase do
    let(:site_base) { SiteBase.new }
    let(:config) { Config.new }

    let(:abstract_methods) do
      %i(
        initialize
        site_name
        problem_url
        working_directory
        login
        submit
        open_submission
      )
    end

    it "raises AbstractMethodCalled for abstract methods" do
      abstract_methods.each do |method|
        expect { site_base.send(method) }.to raise_exception(AbstractMethodCalled)
      end
    end
  end
end
