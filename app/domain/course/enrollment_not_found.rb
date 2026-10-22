module Course
  class EnrollmentNotFound < StandardError
    def initialize
      super("Enrollment not found")
    end
  end
end
