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
    end
  end

  class CLI < Thor
    register Sites::Aoj, :aoj, 'aoj', 'aizu online judge commands'
  end
end
