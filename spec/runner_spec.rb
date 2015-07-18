require "spec_helper"
require "clicoder/builder"
require "clicoder/runner"

module Clicoder
  describe Runner do
    let(:runner) { Runner.new }
    let(:input_file) { File.expand_path('../../fixtures/input.txt', __FILE__) }
    let(:expected_output) { "Hello, World!\n" }

    before do
      begin
        Builder.new.build(file)
      rescue
      end
    end

    describe 'C++ files' do
      let(:file) { File.expand_path('../../fixtures/sample.cpp', __FILE__) }
      it 'runs' do
        output = runner.run(file, input_file)
        expect(output).to eq(expected_output)
      end
    end

    describe 'Script languages' do
      let(:file) { File.expand_path('../../fixtures/sample.rb', __FILE__) }
      it 'runs' do
        output = runner.run(file, input_file)
        expect(output).to eq(expected_output)
      end
    end

    describe 'Unknown files' do
      let(:file) { File.expand_path('../../fixtures/sample.foobar', __FILE__) }
      it 'raises' do
        expect { runner.run(file, input_file) }.to raise_error
      end
    end
  end
end
