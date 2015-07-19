require 'tempfile'
require 'spec_helper'
require 'clicoder/builder'

module Clicoder
  describe Builder do
    let(:builder) { Builder.new() }

    describe 'C++ files' do
      let(:file) { File.expand_path('../../fixtures/sample.cpp', __FILE__) }
      it 'builds' do
        expect(File.exist?('a.out')).to be_falsey
        expect(builder.build(file)).to be true
        expect(File.exist?('a.out')).to be_truthy
      end

      context 'when build fails' do
        let(:tmpfile) { Tempfile.new(['clicoder', '.cpp']) }
        before do
          File.write(tmpfile, File.read(file).tr(';', ''))
        end

        it 'returns false' do
          expect(builder.build(tmpfile.path)).to be false
        end
      end
    end

    describe 'Script languages' do
      let(:file) { File.expand_path('../../fixtures/sample.rb', __FILE__) }
      it 'does nothing' do
        expect(builder.build(file)).to be true
      end
    end

    describe 'Unknown files' do
      let(:file) { File.expand_path('../../fixtures/sample.foobar', __FILE__) }
      it 'raises' do
        expect { builder.build(file) }.to raise_error
      end
    end
  end
end
