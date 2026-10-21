require "spec_helper"
require_relative "../../../app/domain/course/student_id"

RSpec.describe Course::StudentId do
  it "generates a readable identifier from an injected random source" do
    random = instance_double(Random)
    allow(random).to receive(:rand).and_return(0, 1, 2019)

    expect(described_class.generate(random: random)).to eq("curious-hacker-2019")
  end

  it "accepts only readable four-digit identifiers" do
    expect(described_class.valid?("curious-hacker-2019")).to be(true)
    expect(described_class.valid?("Curious-hacker-2019")).to be(false)
    expect(described_class.valid?("curious-hacker-999")).to be(false)
  end
end
