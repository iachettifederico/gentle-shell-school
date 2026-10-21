module Course
  class StudentNotFound < StandardError
    def initialize
      super("Student not found")
    end
  end
end
