require 'clicoder/config'

module Clicoder
  class Runner
    def run(file, input_file)
      raise 'File not found' unless File.exist?(file)
      ext = File.extname(file).tr('.', '')
      conf = Config.new
      run_str = conf.get('languages', ext, 'run')
      return if run_str.nil? || run_str.empty?
      command = run_str.sub('%s', file)
      `#{command} < #{input_file}`
    end
  end
end
