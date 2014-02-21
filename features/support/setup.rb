require 'aruba/cucumber'
require 'aruba/in_process'
require 'cucumber/rspec/doubles'

require 'clicoder/cli'

ENV['PATH'] = "#{Dir.pwd}/bin:#{ENV['PATH']}"

Aruba::InProcess.main_class = Clicoder::ArubaCLI
Aruba.process = Aruba::InProcess

Before do
  # Don't use tmp/aruba dir
  @dirs = ['.']
end

Around do |scenario, block|
  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      ENV['HOME'] = Dir.pwd
      FileUtils.cp_r("#{FIXTURE_DIR}/clicoder.d", '.clicoder.d')

      block.call
    end
  end
end
