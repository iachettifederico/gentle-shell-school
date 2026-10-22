module EnrollmentAccess
  extend ActiveSupport::Concern

  private

  def enrollment_system
    @enrollment_system ||= Course::EnrollmentSystem.new(
      repository: Course::ActiveRecordEnrollmentRepository.new, progress_system: progress_system
    )
  end
end
