module Course
  class EnrollmentExpired < StandardError
    def initialize
      super("Enrollment link expired")
    end
  end
end
