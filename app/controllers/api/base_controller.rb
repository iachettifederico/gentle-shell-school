module Api
  # Agent-facing JSON API: public, read-only, callable from any origin.
  class BaseController < ActionController::API
    include LessonsAccess

    CORS_HEADERS = {
      "Access-Control-Allow-Origin"  => "*",
      "Access-Control-Allow-Methods" => "GET, OPTIONS",
      "Access-Control-Allow-Headers" => "Content-Type",
    }.freeze

    before_action do
      response.headers.merge!(CORS_HEADERS)
    end

    def preflight
      head :no_content
    end
  end
end
