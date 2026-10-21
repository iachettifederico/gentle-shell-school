module Course
  # Raised when lesson content breaks a course invariant. Lessons are authored
  # files, so a broken lesson must fail loudly instead of disappearing.
  class InvalidLesson < StandardError; end
end
