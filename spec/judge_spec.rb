require 'spec_helper'

require 'clicoder'
require 'clicoder/judge'

require 'tempfile'

module Clicoder
  describe Judge do
    let(:judge) { Judge.new( {} ) }

    describe '#diff_judge' do
      before(:all) do
        # input for judge
        @input = Tempfile.new('clicoder')
        @input.write([1, 2, 3].join("\n"))
        @input.close
        @correct_output = Tempfile.new('clicoder')
        @correct_output.write([1, 2, 3].join("\n"))
        @correct_output.close
        @wrong_output = Tempfile.new('clicoder')
        @wrong_output.write([1, 2, 4].join("\n"))
        @wrong_output.close
      end

      it 'returns true when the contents of two files are the same' do
        expect(judge.diff_judge(@input.path, @correct_output.path)).to be_true
      end

      it 'returns false when the contents of two files are different' do
        expect(judge.diff_judge(@input.path, @wrong_output.path)).to be_false
      end
    end

    describe '#float_judge' do
      before(:all) do
        @input = Tempfile.new('clicoder')
        @input.write(<<-EOS)
        0.11 0.11
        0.13 0.13
        EOS
        @input.close
        @output = Tempfile.new('clicoder')
        @output.write(<<-EOS)
        0.12 0.12
        0.12 0.12
        EOS
        @output.close
      end

      subject { judge.float_judge(@input.path, @output.path, abs_error) }

      context 'when diff is less than allowed absolute error' do
        let(:abs_error) { 10**(-1) }
        it { should be_true }
      end

      context 'when diff is less than allowed absolute error' do
        let(:abs_error) { 10**(-2) }
        it { should be_false }
      end
    end
  end
end
