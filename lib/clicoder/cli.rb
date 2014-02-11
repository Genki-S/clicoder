require 'thor'
require 'thor/group'

require 'clicoder/aoj'

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
