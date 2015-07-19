require "clicoder"

module Clicoder
  class Config
    attr_accessor :default, :global, :local

    def initialize
      global_config_file = "#{global_config_dir}/config.yml"
      @default = File.exists?(default_config_file) ? YAML::load_file(default_config_file) : {}
      @global = File.exists?(global_config_file) ? YAML::load_file(global_config_file) : {}
      local_config_file = ".config.yml"
      @local = File.exists?(local_config_file) ? YAML::load_file(local_config_file) : {}
    end

    def default_config_file
      File.join(__dir__, '../../config/default.yml')
    end

    # NOTE: This is not a class variable in order to evaluate stubbed ENV['HOME'] on each RSpec run
    def global_config_dir
      @global_config_dir ||= "#{ENV['HOME']}/.clicoder.d"
    end

    def asset(asset_name)
      site_name = get("site")
      file_name = get("sites", site_name, asset_name)
      if file_name.nil?
        file_name = get("sites", "default", asset_name)
      end

      if file_name.nil?
        return ""
      else
        return File.expand_path(file_name, global_config_dir)
      end
    end

    def merged_config
      @merged_config ||= default.merge(global.merge(local))
    end

    def get(*keys)
      conf = merged_config
      begin
        keys.each do |key|
          conf = conf[key]
        end
        return conf.nil? ? nil : conf
      rescue
        return nil
      end
    end
  end
end
