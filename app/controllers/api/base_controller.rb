module Api
  # Agent-facing JSON API: public, read-only, callable from any origin.
  class BaseController < ActionController::API
    include LessonsAccess
    include ProgressAccess
    include ProgressRendering
    include EnrollmentAccess

    CORS_METHODS = "GET, OPTIONS".freeze

    before_action do
      response.headers.merge!(cors_headers)
    end
    before_action :validate_locale

    rescue_from ArgumentError do |error|
      render json: { error: error.message }, status: :bad_request
    end

    rescue_from ActionDispatch::Http::Parameters::ParseError do
      render json: { error: "Invalid JSON body" }, status: :bad_request
    end

    rescue_from Course::InvalidStudentId, Course::StudentNotFound, Course::UnknownLesson do |error|
      render json: { error: error.message }, status: error.is_a?(Course::StudentNotFound) ? :not_found : :bad_request
    end

    rescue_from Course::EnrollmentNotFound do |error|
      render json: { error: error.message }, status: :not_found
    end

    rescue_from Course::EnrollmentExpired do |error|
      render json: { error: error.message }, status: :gone
    end

    def preflight
      head :no_content
    end

    private

    def requested_locale
      params.fetch(:locale, "en")
    end

    def validate_locale
      return if Course::Locale.valid?(requested_locale)

      render json: { error: "Unsupported locale: #{requested_locale.inspect}" }, status: :bad_request
    end

    def cors_headers
      {
        "Access-Control-Allow-Origin"  => "*",
        "Access-Control-Allow-Methods" => self.class::CORS_METHODS,
        "Access-Control-Allow-Headers" => "Content-Type",
      }
    end
  end
end
