module Api
  # Agent-facing JSON API: public, read-only, callable from any origin.
  class BaseController < ActionController::API
    include LessonsAccess
    include ProgressAccess
    include ProgressRendering

    CORS_METHODS = "GET, OPTIONS".freeze

    before_action do
      response.headers.merge!(cors_headers)
    end

    rescue_from ActionDispatch::Http::Parameters::ParseError do
      render json: { error: "Invalid JSON body" }, status: :bad_request
    end

    rescue_from Course::InvalidStudentId, Course::StudentNotFound, Course::UnknownLesson do |error|
      render json: { error: error.message }, status: error.is_a?(Course::StudentNotFound) ? :not_found : :bad_request
    end

    def preflight
      head :no_content
    end

    private

    def cors_headers
      {
        "Access-Control-Allow-Origin"  => "*",
        "Access-Control-Allow-Methods" => self.class::CORS_METHODS,
        "Access-Control-Allow-Headers" => "Content-Type",
      }
    end
  end
end
