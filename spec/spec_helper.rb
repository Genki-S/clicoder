require 'tmpdir'

require 'webmock/rspec'

GEM_ROOT = Gem::Specification.find_by_name('clicoder').gem_dir
FIXTURE_DIR = GEM_ROOT + '/fixtures'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.around(:each) do |example|
    # Make tmpdir HOME and copy config and template files
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.cp_r("#{FIXTURE_DIR}/clicoder.d", '.clicoder.d')
        ENV['HOME'] = Dir.pwd
        example.run
      end
    end
  end
end
