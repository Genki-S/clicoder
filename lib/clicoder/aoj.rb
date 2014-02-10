module Clicoder
  class AOJ
    @@url_format = 'http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id={{problem_id}}'
    @@inputs_dir = 'inputs'
    @@outputs_dir = 'outputs'
    @@myoutputs_dir = 'myoutputs'

    def initialize(problem_number)
      @problem_id = "%04d" % problem_number
    end

    def start
      Dir.mkdir(@problem_id)
      Dir.chdir(@problem_id) do
        Dir.mkdir(@@inputs_dir)
        Dir.mkdir(@@outputs_dir)
        Dir.mkdir(@@myoutputs_dir)
      end
    end

    def fetch_input
    end

    def get_url
      @@url_format.gsub('{{problem_id}}', "%04d" % @problem_id)
    end
  end
end
