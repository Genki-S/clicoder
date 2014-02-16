require 'spec_helper'

require 'clicoder'
require 'clicoder/config'

module Clicoder
  describe Config do
    let(:config) { Config.new }
    let(:global_config_dir) { "#{ENV['HOME']}/.clicoder.d" }
    let(:global_config_file) { "#{global_config_dir}/config.yml" }
    let(:local_config) { { 'site' => 'default' } }
    let(:local_config_file) { '.config.yml' }

    describe '.new' do
      before do
        File.open(local_config_file, 'w') do |f|
          f.write(local_config.to_yaml)
        end
      end

      it 'loads global configuration from global_config_file' do
        expect(config.global).to eql(YAML::load_file(global_config_file))
      end

      it 'loads local configuration from local_config_file' do
        expect(config.local).to eql(YAML::load_file(local_config_file))
      end
    end

    describe '#template' do
      it 'returns template file' do
        expect(config.template).to eql(YAML::load_file(global_config_file)['default']['template'])
      end
    end

    describe '#makefile' do
      it 'returns makefile file' do
        expect(config.makefile).to eql(YAML::load_file(global_config_file)['default']['makefile'])
      end
    end
  end
end
