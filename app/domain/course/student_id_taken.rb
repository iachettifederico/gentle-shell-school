module Course
  # Raised by a progress repository when a new student's ID is already in use.
  class StudentIdTaken < StandardError; end
end
