require "rails_helper"

RSpec.describe Course::ActiveRecordProgressRepository do
  let(:repository) { described_class.new }

  it "stores and reloads the aggregate through Active Record" do
    progress = Course::StudentProgress.new(
      student_id: "curious-hacker-2019",
      created_at: Time.utc(2025, 1, 1)
    )
    progress.complete("welcome", source: "agent", model: "gpt-5", at: Time.utc(2025, 1, 2))

    repository.create(progress)

    loaded = repository.find("curious-hacker-2019")
    completion = loaded.completions.first
    expect([ loaded.created_at, completion.slug, completion.source, completion.model ])
      .to eq([ Time.utc(2025, 1, 1), "welcome", "agent", "gpt-5" ])
  end

  it "replaces persisted completions with the aggregate state" do
    progress = Course::StudentProgress.new(
      student_id: "curious-hacker-2019",
      created_at: Time.utc(2025, 1, 1)
    )
    repository.create(progress)
    progress.complete("welcome", source: "browser", model: nil, at: Time.utc(2025, 1, 2))

    repository.save(progress)

    expect(LessonCompletion.pluck(:lesson_slug, :source, :model)).to eq([ [ "welcome", "browser", nil ] ])
  end

  it "round-trips completion evidence" do
    progress = Course::StudentProgress.new(student_id: "curious-hacker-2019", created_at: Time.utc(2025, 1, 1))
    evidence = Course::Evidence.new(
      "checks"     => [ { "command" => "bin/rspec", "result" => "pass", "summary" => "42 examples" } ],
      "verifiedBy" => "self"
    )
    progress.complete("welcome", source: "agent", model: nil, evidence: evidence, at: Time.utc(2025, 1, 2))

    repository.create(progress)

    expect(repository.find("curious-hacker-2019").completions.first.evidence.to_h).to eq(evidence.to_h)
  end
end
