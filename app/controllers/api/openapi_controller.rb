module Api
  # Serves the OpenAPI description of the agent API for the requesting origin.
  class OpenapiController < BaseController
    DOCUMENT_PATH = Rails.root.join("config/openapi.yml")

    def show
      document = YAML.safe_load_file(DOCUMENT_PATH)
      render json: document.merge("servers" => [ { "url" => request.base_url } ])
    end
  end
end
