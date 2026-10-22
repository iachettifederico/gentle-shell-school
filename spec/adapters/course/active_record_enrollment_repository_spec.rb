require "rails_helper"

RSpec.describe Course::ActiveRecordEnrollmentRepository do
  let(:repository) { described_class.new }
  let(:created_at) { Time.utc(2025, 1, 2, 12) }

  it "round-trips a pending enrollment" do
    enrollment = Course::PendingEnrollment.new(
      code: "unguessable-code", created_at: created_at, expires_at: created_at + 30.minutes
    )

    repository.create(enrollment)

    record = PendingEnrollment.find_by!(code_digest: Digest::SHA256.hexdigest("unguessable-code"))
    expect(record.attributes).not_to have_key("code")
    expect(record.code_digest).to eq(Digest::SHA256.hexdigest("unguessable-code"))

    loaded = repository.find("unguessable-code")
    expect([ loaded.code, loaded.status, loaded.created_at, loaded.expires_at, loaded.claimed_student_id ])
      .to eq([ "unguessable-code", "pending", created_at, created_at + 30.minutes, nil ])
  end

  it "persists a claimed enrollment linked to its student" do
    enrollment = Course::PendingEnrollment.new(
      code: "unguessable-code", created_at: created_at, expires_at: created_at + 30.minutes
    )
    repository.create(enrollment)
    Student.create!(public_id: "curious-hacker-2019")

    repository.save(enrollment.claim("curious-hacker-2019", at: created_at))

    expect(repository.find("unguessable-code").claimed_student_id).to eq("curious-hacker-2019")
  end
end
