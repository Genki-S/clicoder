require 'webmock/cucumber'

# TODO: DRY. see spec/spec_helper.rb
GEM_ROOT = Gem::Specification.find_by_name('clicoder').gem_dir
FIXTURE_DIR = GEM_ROOT + '/fixtures'
