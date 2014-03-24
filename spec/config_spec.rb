require 'spec_helper'

require 'clicoder'
require 'clicoder/config'

module Clicoder
  describe Config do
    let(:config) { Config.new }
    let(:global_config) { YAML::load_file(global_config_file) }
    let(:global_config_dir) { "#{ENV['HOME']}/.clicoder.d" }
    let(:global_config_file) { "#{global_config_dir}/config.yml" }
    let(:local_config) { { 'site' => 'sample_site' } }
    let(:local_config_file) { '.config.yml' }

    before do
      File.open(local_config_file, 'w') do |f|
        f.write(local_config.to_yaml)
      end
    end

    describe '.new' do
      it 'loads global configuration from global_config_file' do
        expect(config.global).to eql(global_config)
      end

      it 'loads local configuration from local_config_file' do
        expect(config.local).to eql(local_config)
      end
    end

    describe '#asset' do
      context 'when the site specific asset is specified in the config file' do
        it 'returns site specific template' do
          site = local_config['site']
          file_name = global_config[site]['template']
          expect(config.asset('template')).to eql(File.expand_path(file_name, global_config_dir))
        end
      end

      context 'when the site specific asset is not specified in the config file' do
        before do
          config.global[local_config['site']] = {}
        end

        it 'returns default template' do
          file_name = global_config['default']['template']
          expect(config.asset('template')).to eql(File.expand_path(file_name, global_config_dir))
        end
      end

      context 'when nothing is specified in the config file' do
        before do
          config.global = {}
        end

        it 'returns empty string' do
          expect(config.asset('template')).to eql('')
        end
      end
    end

    describe '#get' do
      context 'without arguments' do
        it 'returns config.global.merge(config.local)' do
          expect(config.get()).to eql(config.global.merge(config.local))
        end
      end

      context 'with arguments' do
        context 'when config is missing' do
          it 'returns empty string' do
            expect(config.get('it', 'is', 'missing')).to eql('')
          end
        end

        context 'when config is present' do
          it 'returns the config value' do
            expect(config.get('sample_site', 'user_id')).to eql(global_config['sample_site']['user_id'])
          end
        end
      end
    end
  end
end
