require 'aruba/cucumber'

ENV['PATH'] = "#{Dir.pwd}/bin:#{ENV['PATH']}"

Before do
  # Don't use tmp/aruba dir
  @dirs = ['.']
  # Wait longer
  @aruba_timeout_seconds = 10
end

Around do |scenario, block|
  config = File.expand_path('fixtures/config.yml', Dir.pwd)
  template = File.expand_path('fixtures/template.cpp', Dir.pwd)
  makefile = File.expand_path('fixtures/Makefile', Dir.pwd)

  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      [config, template, makefile].each do |file|
        FileUtils.cp(file, '.')
      end

      block.call
    end
  end
end
