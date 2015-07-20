require "spec_helper"

require "clicoder/config"
require "clicoder/sites/aoj"

require "reverse_markdown"

module Clicoder
  describe AOJ do
    let(:problem_number) { 2555 }
    let(:aoj) { AOJ.new(problem_number) }
    let(:config) { aoj.config }

    before do
      stub_request(:get, "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=#{problem_number}").
        to_return(status: 200,
                  body: File.read("#{FIXTURE_DIR}/sites/aoj/#{problem_number}.html"))
    end

    describe "#start" do
      before do
        aoj.start
      end

      it "creates working directory specified by #working_directory" do
        expect(File.directory?(aoj.working_directory)).to be true
      end

      it "stores description as markdown" do
        description_string = "You are very absorbed in a famous role-playing game"
        Dir.chdir(aoj.working_directory) do
          expect(File.read("description.md")).to match(description_string)
        end
      end

      it "stores sample input and output files" do
        sample_count = 5
        # from AOJ problem 2555
        sample_inputs = [
          "2 2\n2\n1 >= 3\n2 <= 5\n2\n1 >= 4\n2 >= 3\n",
          "2 2\n2\n1 >= 5\n2 >= 5\n2\n1 <= 4\n2 <= 3\n",
          "2 2\n2\n1 >= 3\n2 <= 3\n2\n1 <= 2\n2 >= 5\n",
          "1 2\n2\n1 <= 10\n1 >= 15\n",
          "5 5\n3\n2 <= 1\n3 <= 1\n4 <= 1\n4\n2 >= 2\n3 <= 1\n4 <= 1\n5 <= 1\n3\n3 >= 2\n4 <= 1\n5 <= 1\n2\n4 >= 2\n5 <= 1\n1\n5 >= 2\n",
        ]
        sample_outputs = ["Yes\n", "Yes\n", "No\n", "No\n", "Yes\n"]

        Dir.chdir(aoj.working_directory) do
          sample_count.times do |i|
            expect(File.exist?("inputs/#{i}")).to be true
            expect(File.exist?("outputs/#{i}")).to be true
            expect(File.read("inputs/#{i}")).to eq(sample_inputs[i])
            expect(File.read("outputs/#{i}")).to eq(sample_outputs[i])
          end
        end
      end
    end
  end
end
