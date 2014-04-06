require 'clicoder'

module Clicoder
  class Config
    attr_accessor :global, :local

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

    def asset(asset_name)
      site_name = get('site')
      file_name = get(site_name, asset_name)
      if file_name.empty?
        file_name = get('default', asset_name)
      end

      unless file_name.empty?
        return File.expand_path(file_name, global_config_dir)
      else
        return ''
      end
    end

    def merged_config
      @merged_config ||= global.merge(local)
    end

    def get(*keys)
      conf = merged_config
      begin
        keys.each do |key|
          conf = conf[key]
        end
        return conf.nil? ? '' : conf
      rescue
        return ''
      end
    end

  end
end
