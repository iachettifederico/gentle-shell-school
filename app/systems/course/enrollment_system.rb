module Course
  # Coordinates agent-created enrollment links with anonymous student progress.
  class EnrollmentSystem
    def initialize(repository:, progress_system:, clock: -> { Time.now.utc }, random: SecureRandom)
      @repository = repository
      @progress_system = progress_system
      @clock = clock
      @random = random
    end

    def prepare
      @repository.create(PendingEnrollment.prepare(clock: @clock, random: @random))
    end

    def status(code)
      enrollment = find(code)
      raise EnrollmentExpired if enrollment.expired?(at: now)

      enrollment
    end

    def claim(code)
      @repository.transaction do
        enrollment = find_for_claim(code)
        enrollment.assert_claimable(at: now)
        progress = @progress_system.enroll
        @repository.save(enrollment.claim(progress.student_id, at: now))
      end
    end

    private

    def find(code)
      @repository.find(code) || raise(EnrollmentNotFound)
    end

    def find_for_claim(code)
      @repository.find_for_claim(code) || raise(EnrollmentNotFound)
    end

    def now
      @clock.call
    end
  end
end
