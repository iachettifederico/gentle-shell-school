module Api
  # Serves the OpenAPI description of the agent API for the requesting origin.
  class OpenapiController < BaseController
    DOCUMENT_PATH = Rails.root.join("config/openapi.yml")

    def show
      document = YAML.safe_load_file(DOCUMENT_PATH)
      description = document.dig("info", "description")
      document["info"]["description"] = format(description, feedback_repository: feedback_repository)
      render json: document.merge("servers" => [ { "url" => request.base_url } ])
    end

    private

    def feedback_repository
      Rails.configuration.x.course.feedback_repository
    end
  end
end
