require "spec_helper"
require_relative "../../../app/domain/course/student_progress"

RSpec.describe Course::StudentProgress do
  let(:created_at) { Time.utc(2025, 1, 1, 12) }
  let(:progress) { described_class.new(created_at: created_at) }

  it "records a normalized completion and updates its timestamp" do
    completed_at = Time.utc(2025, 1, 2, 12)

    progress.complete("welcome", source: "agent", model: "  gpt-5  ", at: completed_at)

    values = progress.completions.map { |completion|
      [ completion.slug, completion.completed_at, completion.source, completion.model ]
    }
    expect(values).to eq([ [ "welcome", completed_at, "agent", "gpt-5" ] ])
    expect(progress.updated_at).to eq(completed_at)
  end

  it "defaults non-agent sources and blank models" do
    progress.complete("welcome", source: "Agent", model: "   ", at: Time.utc(2025, 1, 2))

    completion = progress.completions.first
    expect([ completion.source, completion.model ]).to eq([ "browser", nil ])
  end

  it "keeps the original completion when completing a lesson again" do
    original_time = Time.utc(2025, 1, 2)
    progress.complete("welcome", source: "browser", model: nil, at: original_time)

    progress.complete("welcome", source: "agent", model: "new-model", at: Time.utc(2025, 1, 3))

    completion = progress.completions.first
    expect([ completion.completed_at, completion.source, completion.model ]).to eq([ original_time, "browser", nil ])
    expect(progress.updated_at).to eq(Time.utc(2025, 1, 3))
  end

  it "sorts completions by completion time" do
    progress.complete("later", source: "browser", model: nil, at: Time.utc(2025, 1, 3))
    progress.complete("earlier", source: "browser", model: nil, at: Time.utc(2025, 1, 2))

    expect(progress.completions.map(&:slug)).to eq(%w[earlier later])
  end

  it "removes one completion and updates its timestamp" do
    progress.complete("welcome", source: "browser", model: nil, at: Time.utc(2025, 1, 2))
    progress.uncomplete("welcome", at: Time.utc(2025, 1, 3))

    expect(progress.completions).to eq([])
    expect(progress.updated_at).to eq(Time.utc(2025, 1, 3))
  end

  it "resets all completions and keeps its creation time" do
    progress.complete("welcome", source: "browser", model: nil, at: Time.utc(2025, 1, 2))
    progress.reset(at: Time.utc(2025, 1, 3))

    expect(progress.completions).to eq([])
    expect([ progress.created_at, progress.updated_at ]).to eq([ created_at, Time.utc(2025, 1, 3) ])
  end
end
