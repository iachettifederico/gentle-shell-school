module Api
  class EnrollController < BaseController
    CORS_METHODS = "POST, OPTIONS".freeze

    def create
      params.to_unsafe_h
      progress = progress_system.enroll
      render json: { studentId: progress.student_id, progress: progress_json(progress) }, status: :created
    end
  end
end
