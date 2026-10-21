module Api
  class ProgressController < BaseController
    CORS_METHODS = "GET, PUT, DELETE, OPTIONS".freeze

    def show
      render json: progress_json(progress_system.progress_for(params[:student_id]))
    end

    def update
      return render_lesson_slug_error unless valid_lesson_slug?

      progress = progress_system.complete_lesson(
        params[:student_id], lesson_slug: params[:lessonSlug], source: params[:source], model: params[:model]
      )
      render json: progress_json(progress)
    end

    def destroy
      return render_reset if params[:reset] == true
      return render_delete_fields_error unless params.key?(:lessonSlug)
      return render_lesson_slug_error unless valid_lesson_slug?

      render json: progress_json(uncomplete_lesson)
    end

    private

    def valid_lesson_slug?
      params[:lessonSlug].is_a?(String) && params[:lessonSlug].present?
    end

    def render_reset
      render json: progress_json(progress_system.reset(params[:student_id]))
    end

    def render_delete_fields_error
      render json: { error: 'Provide "lessonSlug" or "reset": true' }, status: :bad_request
    end

    def render_lesson_slug_error
      render json: { error: 'Missing or invalid "lessonSlug" field' }, status: :bad_request
    end

    def uncomplete_lesson
      progress_system.uncomplete_lesson(params[:student_id], lesson_slug: params[:lessonSlug])
    end
  end
end
