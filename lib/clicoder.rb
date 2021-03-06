require "clicoder/version"

module Clicoder
  GEM_ROOT = Gem::Specification.find_by_name("clicoder").gem_dir

  INPUTS_DIRNAME = "inputs"
  OUTPUTS_DIRNAME = "outputs"
  MY_OUTPUTS_DIRNAME = "my_outputs"

  module Helper
    def detect_main
      Dir.glob("main.*").first
    end

    def ext_to_language_name(ext)
      @map ||= {
        cpp: "C++",
        cc: "C++",
        c: "C",
        java: "JAVA",
        cs: "C#",
        d: "D",
        rb: "Ruby",
        py: "Python",
        php: "PHP"
      }
      @map[ext.gsub(/^\./, "").to_sym]
    end
  end
end
