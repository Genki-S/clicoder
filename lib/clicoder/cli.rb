require "thor"
require "thor/group"
require "launchy"

require "clicoder/builder"
require "clicoder/runner"
require "clicoder/judge"
require "clicoder/site_base"
require "clicoder/sites/sample_site"
require "clicoder/sites/aoj"
require "clicoder/sites/atcoder"

module Clicoder
  class Starter < Thor
    desc "sample_site", "Prepare directory to deal with new problem from SampleSite"
    def sample_site
      sample_site = SampleSite.new
      start_with(sample_site)
    end

    desc "aoj PROBLEM_NUMBER", "Prepare directory to deal with new problem from AOJ"
    def aoj(problem_number)
      aoj = AOJ.new(problem_number)
      start_with(aoj)
    end

    desc "atcoder TASK_URL", "Prepare directory to deal with new problem from AtCoder"
    def atcoder(task_url)
      match_regexp = %r{http://([^.]*)\.contest\.atcoder\.jp/tasks/(.*)}
      if task_url.match(match_regexp)
        contest_id, task_id = task_url.match(match_regexp)[1, 2]
      else
        raise ArgumentError, "Please provide a valid atcoder task url."
      end

      atcoder = AtCoder.new(contest_id, task_id)
      start_with(atcoder)
    end

    no_commands do
      def start_with(site)
        site.start
        puts "created directory #{site.working_directory}"
      end
    end
  end

  class CLI < Thor
    include Helper

    desc "all", "build, execute, and judge"
    def all
      invoke :build
      invoke :execute
      invoke :judge
    end

    desc "build", "Build your program"
    def build
      load_local_config
      builder = Builder.new
      builder.build(detect_main)
    end

    desc "execute", "Execute your program"
    def execute
      load_local_config
      runner = Runner.new
      Dir.glob("#{INPUTS_DIRNAME}/*").each do |input|
        File.write("#{MY_OUTPUTS_DIRNAME}/#{File.basename(input)}", runner.run(detect_main, input))
      end
    end

    desc "judge", "Judge your outputs"
    method_option :decimal,
                  type: :numeric, aliases: "-d",
                  desc: "Decimal position of allowed absolute error"
    def judge
      load_local_config
      accepted = true
      judge = Judge.new(options)
      Dir.glob("#{OUTPUTS_DIRNAME}/*").each do |output|
        puts "judging #{output}"
        my_output = "#{MY_OUTPUTS_DIRNAME}/#{File.basename(output)}"
        if File.exists?(my_output)
          unless judge.judge(output, my_output)
            puts "! Wrong Answer"
            system("diff -y #{output} #{my_output}")
            accepted = false
          end
        else
          puts "! #{my_output} does not exist"
          accepted = false
        end
      end
      if accepted
        puts "Correct Answer"
      else
        puts "Wrong Answer"
      end
    end

    desc "submit", "Submit your program"
    def submit
      load_local_config
      site = get_site
      if site.submit
        puts "Submission Succeeded."
        site.open_submission
      else
        puts "Submission Failed."
        exit 1
      end
    end

    desc "add_test", "Add new test case"
    def add_test
      load_local_config
      test_number = 0
      while File.exist?("#{INPUTS_DIRNAME}/#{test_number}")
        test_number += 1
      end
      input_file = "#{INPUTS_DIRNAME}/#{test_number}"
      output_file = "#{OUTPUTS_DIRNAME}/#{test_number}"
      puts "Input:"
      system("cat > #{input_file}")
      puts "Output:"
      system("cat > #{output_file}")
    end

    desc "download", "Download description, inputs and outputs"
    def download
      load_local_config
      site = get_site
      # TODO: this is not beautiful
      Dir.chdir("..") do
        site.download_description
        site.download_inputs
        site.download_outputs
      end
    end

    desc "browse", "Open problem page with the browser"
    def browse
      load_local_config
      site = get_site
      Launchy.open(site.problem_url)
    end

    no_commands do
      def load_local_config
        unless File.exists?(".config.yml")
          puts "It seems you are not in probelm directory"
          exit 1
        end
        @local_config = YAML::load_file(".config.yml")
      end

      def get_site
        SiteBase.new_with_config(@local_config)
      end
    end
    register Starter, "new", "new <command>", "start a new problem"
  end

  # Use aruba in-process
  # https://github.com/cucumber/aruba
  # https://github.com/erikhuda/thor/wiki/Integrating-with-Aruba-In-Process-Runs
  class ArubaCLI
    def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
      @argv = argv
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
      @kernel = kernel
    end

    def execute!
      exit_code = begin
        # Thor accesses these streams directly rather than letting them be injected, so we replace them...
        $stderr = @stderr
        $stdin = @stdin
        $stdout = @stdout

        # Run our normal Thor app the way we know and love.
        CLI.start(@argv)

        # Thor::Base#start does not have a return value, assume success if no exception is raised.
        0
      rescue Exception => e
        # Proxy any exception that comes out of Thor itself back to stderr
        $stderr.write(e.message + "\n")

        # Exit with a failure code.
        1
      ensure
        # ...then we put them back.
        $stderr = STDERR
        $stdin = STDERR
        $stdout = STDERR
      end

      # Proxy our exit code back to the injected kernel.
      @kernel.exit(exit_code)
    end
  end
end
