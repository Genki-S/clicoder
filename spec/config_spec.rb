require 'spec_helper'

require 'clicoder'
require 'clicoder/aoj'
require 'clicoder/config'

module Clicoder
  describe Config do
    let(:config) { Config.new }
    let(:global_config_dir) { "#{ENV['HOME']}/.clicoder.d" }
    let(:global_config_file) { "#{global_config_dir}/config.yml" }
    let(:local_config_file) { '.config.yml' }

    describe '.new' do
      before do
        # Start new problem with AOJ
        aoj = AOJ.new(1)
        aoj.start
        Dir.chdir(aoj.work_dir)
      end

      it 'loads global configuration from global_config_file' do
        expect(config.global).to eql(YAML::load_file(global_config_file))
      end

      it 'loads local configuration from local_config_file' do
        expect(config.local).to eql(YAML::load_file(local_config_file))
      end
    end
  end
end
