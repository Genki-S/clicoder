require "webmock/cucumber"

# TODO: DRY. see spec/spec_helper.rb
GEM_ROOT = Gem::Specification.find_by_name("clicoder").gem_dir
FIXTURE_DIR = GEM_ROOT + "/fixtures"

Before do
  # TODO: DRY. see spec/spec_helper.rb
  stub_request(:get, "http://samplesite.com/sample_problem.html").
    to_return(status: 200,
              body: File.read("#{FIXTURE_DIR}/sample_problem.html"))
end
