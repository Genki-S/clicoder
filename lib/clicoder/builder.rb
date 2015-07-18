require 'clicoder/config'

module Clicoder
  class Builder
    def build(file)
      raise 'File not found' unless File.exist?(file)
      ext = File.extname(file).tr('.', '')
      conf = Config.new
      build_str = conf.get('languages', ext, 'build')
      return true if build_str.nil? || build_str.empty?
      command = build_str.sub('%s', file)
      system(command)
    end
  end
end
