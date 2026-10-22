require "spec_helper"
require_relative "../../../app/domain/course/enrollment_already_claimed"
require_relative "../../../app/domain/course/enrollment_expired"
require_relative "../../../app/domain/course/pending_enrollment"

RSpec.describe Course::PendingEnrollment do
  let(:clock) { -> { Time.utc(2025, 1, 2, 12) } }
  let(:random) { double(urlsafe_base64: "unguessable-code") }

  it "prepares an unclaimed enrollment that expires after thirty minutes" do
    enrollment = described_class.prepare(clock: clock, random: random)

    expect([ enrollment.code, enrollment.status, enrollment.created_at, enrollment.expires_at ])
      .to eq([ "unguessable-code", "pending", Time.utc(2025, 1, 2, 12), Time.utc(2025, 1, 2, 12, 30) ])
  end

  it "expires only while unclaimed and preserves a claimed enrollment after expiry" do
    enrollment = described_class.prepare(clock: clock, random: random)
    claimed = enrollment.claim("curious-hacker-2019", at: Time.utc(2025, 1, 2, 12, 29))

    expect(enrollment.expired?(at: Time.utc(2025, 1, 2, 12, 30))).to be(true)
    expect(claimed.expired?(at: Time.utc(2025, 1, 2, 13))).to be(false)
    expect(claimed.claimed_student_id).to eq("curious-hacker-2019")
  end

  it "rejects claims after expiry and repeated claims" do
    enrollment = described_class.prepare(clock: clock, random: random)

    expect { enrollment.claim("curious-hacker-2019", at: Time.utc(2025, 1, 2, 12, 30)) }
      .to raise_error(Course::EnrollmentExpired)
    claimed = enrollment.claim("curious-hacker-2019", at: Time.utc(2025, 1, 2, 12, 1))
    expect { claimed.claim("bright-maker-2020", at: Time.utc(2025, 1, 2, 12, 2)) }
      .to raise_error(Course::EnrollmentAlreadyClaimed)
  end
end
