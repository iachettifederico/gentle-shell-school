module Course
  class EnrollmentAlreadyClaimed < StandardError
    def initialize
      super("Enrollment already used")
    end
  end
end
