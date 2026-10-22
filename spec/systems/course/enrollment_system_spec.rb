require "rails_helper"

RSpec.describe Course::EnrollmentSystem do
  let(:clock) { -> { Time.utc(2025, 1, 2, 12) } }
  let(:repository) { Course::ActiveRecordEnrollmentRepository.new }
  let(:id_generator) { double(generate: "curious-hacker-2019") }
  let(:progress_system) {
    Course::ProgressSystem.new(
      repository:     Course::ActiveRecordProgressRepository.new,
      lessons_system: double,
      id_generator:   id_generator,
      clock:          clock
    )
  }
  let(:system) {
    described_class.new(
      repository: repository, progress_system: progress_system, clock: clock,
      random: double(urlsafe_base64: "unguessable-code")
    )
  }

  it "claims an enrollment once and leaves the second claim without a new student" do
    enrollment = system.prepare

    claimed = system.claim(enrollment.code)

    expect(claimed.claimed_student_id).to eq("curious-hacker-2019")
    expect { system.claim(enrollment.code) }.to raise_error(Course::EnrollmentAlreadyClaimed, "Enrollment already used")
    expect(Student.pluck(:public_id)).to eq([ "curious-hacker-2019" ])
  end

  it "does not create a student for an expired enrollment" do
    repository.create(Course::PendingEnrollment.new(
                        code: "expired", created_at: clock.call - 31.minutes, expires_at: clock.call - 1.minute
                      ))

    expect { system.claim("expired") }.to raise_error(Course::EnrollmentExpired, "Enrollment link expired")
    expect(Student.count).to eq(0)
  end
end
