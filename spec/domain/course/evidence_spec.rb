require "spec_helper"
require_relative "../../../app/domain/course/evidence"

RSpec.describe Course::Evidence do
  it "keeps valid check evidence" do
    evidence = described_class.new(
      "checks"     => [ { "command" => "bin/rspec", "result" => "pass", "summary" => "42 examples" } ],
      "verifiedBy" => "independent-verifier"
    )

    expect(evidence.to_h).to eq(
      checks:     [ { command: "bin/rspec", result: "pass", summary: "42 examples" } ],
      verifiedBy: "independent-verifier"
    )
  end

  it "rejects a missing check command" do
    expect {
      described_class.new("checks" => [ { "result" => "pass", "summary" => "42 examples" } ], "verifiedBy" => "self")
    }.to raise_error(Course::InvalidEvidence, 'Invalid "evidence" field')
  end

  it "rejects invalid check counts, text, results, and verifiers" do
    invalid_evidence.each do |value|
      expect { described_class.new(value) }.to raise_error(Course::InvalidEvidence, 'Invalid "evidence" field')
    end
  end

  def invalid_evidence
    [
      { "checks" => [], "verifiedBy" => "self" },
      { "checks" => Array.new(11, valid_check), "verifiedBy" => "self" },
      { "checks" => [ valid_check.merge("command" => " ") ], "verifiedBy" => "self" },
      { "checks" => [ valid_check.merge("summary" => "x" * 501) ], "verifiedBy" => "self" },
      { "checks" => [ valid_check.merge("result" => "pending") ], "verifiedBy" => "self" },
      { "checks" => [ valid_check ], "verifiedBy" => "agent" },
    ]
  end

  def valid_check
    { "command" => "bin/rspec", "result" => "pass", "summary" => "42 examples" }
  end
end
