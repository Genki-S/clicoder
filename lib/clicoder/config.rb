require 'clicoder'

module Clicoder
  class Config
    attr_reader :global, :local

    def initialize
      global_config_file = "#{global_config_dir}/config.yml"
      @global = File.exists?(global_config_file) ? YAML::load_file(global_config_file) : {}
      local_config_file = '.config.yml'
      @local = File.exists?(local_config_file) ? YAML::load_file(local_config_file) : {}
    end

    # NOTE: This is not a class variable in order to evaluate stubbed ENV['HOME'] on each RSpec run
    def global_config_dir
      @global_config_dir ||= "#{ENV['HOME']}/.clicoder.d"
    end

    def template
      @global['default']['template']
    end

    def makefile
      @global['default']['makefile']
    end

    def merged_config
      global.merge(local)
    end

    def get(keys = [])
      conf = merged_config
      begin
        keys.each do |key|
          conf = conf[key]
        end
        return conf
      rescue
        return ''
      end
    end

  end
end
