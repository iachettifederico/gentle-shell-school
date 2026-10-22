require "securerandom"

module Course
  # An agent-prepared enrollment link that a student voluntarily claims.
  class PendingEnrollment
    LIFETIME = 30 * 60

    def self.prepare(clock:, random: SecureRandom)
      created_at = clock.call
      new(code: random.urlsafe_base64(24), created_at: created_at, expires_at: created_at + LIFETIME)
    end

    def initialize(code:, created_at:, expires_at:, status: "pending", claimed_student_id: nil)
      @code = code
      @created_at = created_at
      @expires_at = expires_at
      @status = status
      @claimed_student_id = claimed_student_id
    end

    def code = @code
    def created_at = @created_at
    def expires_at = @expires_at
    def status = @status
    def claimed_student_id = @claimed_student_id

    def expired?(at:)
      @status == "pending" && @expires_at <= at
    end

    def claim(student_id, at:)
      assert_claimable(at: at)
      self.class.new(code: @code, created_at: @created_at, expires_at: @expires_at,
                     status: "enrolled", claimed_student_id: student_id)
    end

    def assert_claimable(at:)
      raise EnrollmentAlreadyClaimed if @status == "enrolled"
      raise EnrollmentExpired if expired?(at: at)
    end
  end
end
