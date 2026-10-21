module Course
  class InvalidStudentId < StandardError
    def initialize
      super("Invalid student ID format")
    end
  end
end
