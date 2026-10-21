# Wires the progress facade to the Rails persistence and configured lesson catalog.
module ProgressAccess
  extend ActiveSupport::Concern

  private

  def progress_system
    @progress_system ||= Course::ProgressSystem.new(
      repository:     Course::ActiveRecordProgressRepository.new,
      lessons_system: lessons_system
    )
  end
end
