require 'thor'
require 'thor/group'

require 'clicoder/judge'
require 'clicoder/sites/sample_site'
require 'clicoder/sites/aoj'

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

    no_commands do
      def start_with(site)
        site.start
        puts "created directory #{site.working_directory}"
      end
    end
  end

  class CLI < Thor
    desc "build", "Build your program using `make build`"
    def build
      load_local_config
      status = system('make build')
      exit status
    end

    desc "execute", "Execute your program using `make run`"
    def execute
      load_local_config
      Dir.glob("#{INPUTS_DIRNAME}/*.txt").each do |input|
        puts "executing #{input}"
        FileUtils.cp(input, TEMP_INPUT_FILENAME)
        system("make execute")
        FileUtils.cp(TEMP_OUTPUT_FILENAME, "#{MY_OUTPUTS_DIRNAME}/#{File.basename(input)}")
      end
      FileUtils.rm([TEMP_INPUT_FILENAME, TEMP_OUTPUT_FILENAME])
    end

    desc "judge", "Judge your outputs"
    method_option :decimal, type: :numeric, aliases: '-d', desc: 'Decimal position of allowed absolute error'
    def judge
      load_local_config
      accepted = true
      judge = Judge.new(options)
      Dir.glob("#{OUTPUTS_DIRNAME}/*.txt").each do |output|
        puts "judging #{output}"
        my_output =  "#{MY_OUTPUTS_DIRNAME}/#{File.basename(output)}"
        if File.exists?(my_output)
          unless judge.judge(output, my_output)
            puts '! Wrong Answer'
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
      test_count = Dir.glob("#{INPUTS_DIRNAME}/*.txt").count
      input_file = "#{INPUTS_DIRNAME}/#{test_count}.txt"
      output_file = "#{OUTPUTS_DIRNAME}/#{test_count}.txt"
      puts 'Input:'
      system("cat > #{input_file}")
      puts 'Output:'
      system("cat > #{output_file}")
    end

    no_commands do
      def load_local_config
        unless File.exists?('.config.yml')
          puts 'It seems you are not in probelm directory'
          exit 1
        end
        @local_config = YAML::load_file('.config.yml')
      end

      def get_site
        case @local_config['site']
        when 'sample_site'
          SampleSite.new
        when 'aoj'
          AOJ.new(@local_config['problem_number'])
        end
      end
    end
    register Starter, 'new', 'new <command>', 'start a new problem'
  end

  # Use aruba in-process
  # https://github.com/cucumber/aruba
  # https://github.com/erikhuda/thor/wiki/Integrating-with-Aruba-In-Process-Runs
  class ArubaCLI
    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
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
