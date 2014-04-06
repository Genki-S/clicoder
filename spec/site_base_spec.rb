require 'spec_helper'

require 'clicoder/site_base'
require 'clicoder/config'

require 'nokogiri'
require 'abstract_method'

module Clicoder
  describe SiteBase do
    let(:site_base) { SiteBase.new }
    let(:config) { Config.new }

    let(:abstract_methods) do
      %i(
        site_name
        problem_url
        description_xpath
        inputs_xpath
        outputs_xpath
        working_directory

        login
        submit
        open_submission
      )
    end

    it 'raises AbstractMethodCalled for abstract methods' do
      abstract_methods.each do |method|
        expect{ site_base.send(method) }.to raise_exception(AbstractMethodCalled)
      end
    end

    describe '#config' do
      it 'returns config object' do
        expect(site_base.config).to be_a Config
      end
    end
  end
end
