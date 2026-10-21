module Api
  class InstructionsController < BaseController
    CORS_METHODS = "GET, OPTIONS".freeze

    def show
      progress_system.progress_for(params[:student_id])
      render plain: instructions, content_type: "text/plain"
    end

    private

    def instructions
      <<~TEXT
        My Gentle Shell School student ID is #{params[:student_id]}

        Give this ID to your agent when it teaches this course so it can record completed lessons. Read #{request.base_url}/llms.txt for the API and teaching instructions.
      TEXT
    end
  end
end
