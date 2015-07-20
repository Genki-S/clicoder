require "spec_helper"

require "clicoder/config"
require "clicoder/sites/atcoder"

require "reverse_markdown"

module Clicoder
  describe AtCoder do
    let(:contest_id) { "arc001" }
    let(:task_id) { "arc001_1" }
    let(:atcoder) { AtCoder.new(contest_id, task_id) }
    let(:config) { atcoder.config }

    before do
      stub_request(:get, "http://#{contest_id}.contest.atcoder.jp/tasks/#{task_id}").
        to_return(status: 200,
                  body: File.read("#{FIXTURE_DIR}/sites/atcoder/#{task_id}.html"))
      stub_request(:get, "http://#{contest_id}.contest.atcoder.jp/login").
        to_return(status: 200,
                  body: File.read("#{FIXTURE_DIR}/sites/atcoder/#{contest_id}_login.html"),
                  headers: { 'Content-Type' => 'text/html' })
      stub_request(:post, "http://arc001.contest.atcoder.jp/login").
        to_return(status: 200)
    end

    describe "#start" do
      before do
        atcoder.start
      end

      it "creates working directory specified by #working_directory" do
        expect(File.directory?(atcoder.working_directory)).to be true
      end

      it "stores description as markdown" do
        description_string = "高橋君はセンター試験を受けました"
        Dir.chdir(atcoder.working_directory) do
          expect(File.read("description.md")).to match(description_string)
        end
      end

      it "stores sample input and output files" do
        sample_count = 3
        # from AtCoder problem arc001_1
        sample_inputs = [
          "9\n131142143\n",
          "20\n12341234123412341234\n",
          "4\n1111\n",
        ]
        sample_outputs = ["4 1\n", "5 5\n", "4 0\n"]

        Dir.chdir(atcoder.working_directory) do
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
