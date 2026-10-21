# Gives controllers the lessons system, wired to the configured lessons directory.
module LessonsAccess
  extend ActiveSupport::Concern

  private

  def lessons_system
    @lessons_system ||= Course::LessonsSystem.new(
      repository: Course::FileLessonRepository.new(directory: Rails.configuration.x.lessons_directory)
    )
  end
end
