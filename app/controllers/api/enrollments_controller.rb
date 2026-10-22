module Api
  class EnrollmentsController < BaseController
    CORS_METHODS = "GET, POST, OPTIONS".freeze

    def show
      enrollment = enrollment_system.status(params[:code])
      render json: enrollment.status == "pending" ? pending_status_json(enrollment) : enrolled_json(enrollment)
    end

    def create
      enrollment = enrollment_system.prepare
      render json: pending_json(enrollment), status: :created
    end

    private

    def pending_json(enrollment)
      pending_status_json(enrollment).merge(code: enrollment.code, enrollUrl: enroll_url(code: enrollment.code))
    end

    def pending_status_json(enrollment)
      { status: enrollment.status, expiresAt: enrollment.expires_at.iso8601 }
    end

    def enrolled_json(enrollment)
      progress = progress_system.progress_for(enrollment.claimed_student_id)
      pending_status_json(enrollment).merge(studentId: progress.student_id, progress: progress_json(progress))
    end
  end
end
