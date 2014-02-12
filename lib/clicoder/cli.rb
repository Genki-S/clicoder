require 'thor'
require 'thor/group'

require 'clicoder/aoj'
require 'clicoder/judge'

module Clicoder
  module Sites
    class Aoj < Thor
      desc "new PROBLEM_NUMBER", "Prepare directory to deal with new problem"
      def new(problem_number)
        aoj = AOJ.new(problem_number)
        aoj.start
        puts "created directory #{aoj.work_dir}"
      end

      desc "build", "Build your program using `make build`"
      def build
        ensure_in_problem_directory
        status = system('make build')
        exit status
      end

      desc "execute", "Execute your program using `make run`"
      def execute
        ensure_in_problem_directory
        Dir.glob("#{INPUTS_DIRNAME}/*.txt").each do |input|
          puts "executing #{input}"
          FileUtils.cp(input, TEMP_INPUT_FILENAME)
          system("make execute")
          FileUtils.cp(TEMP_OUTPUT_FILENAME, "#{MY_OUTPUTS_DIRNAME}/#{File.basename(input)}")
        end
        FileUtils.rm([TEMP_INPUT_FILENAME, TEMP_OUTPUT_FILENAME])
      end

      desc "judge", "Judge your outputs"
      def judge
        ensure_in_problem_directory
        accepted = true
        judge = Judge.new
        Dir.glob("#{MY_OUTPUTS_DIRNAME}/*.txt").each do |my_output|
          puts "judging #{my_output}"
          accepted = false unless judge.judge(my_output, "#{OUTPUTS_DIRNAME}/#{File.basename(my_output)}")
        end
        if accepted
          puts "Correct Answer"
        else
          puts "Wrong Answer"
        end
        exit accepted ? 0 : 1
      end

      no_commands do
        def ensure_in_problem_directory
          @cwd = File.basename(Dir.pwd)
          unless /\d+/ === @cwd
            puts 'It seems you are not in probelm directory'
            exit 1
          end
        end
      end
    end
  end

  class CLI < Thor
    register Sites::Aoj, :aoj, 'aoj', 'aizu online judge commands'
  end
end
