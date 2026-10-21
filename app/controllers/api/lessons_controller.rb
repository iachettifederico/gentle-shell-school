module Api
  class LessonsController < BaseController
    def index
      render json: lessons_system.lessons.map { |lesson| lesson_json(lesson) }
    end

    def show
      lesson = lessons_system.find_lesson(params[:slug])
      return render json: { error: "Lesson not found" }, status: :not_found unless lesson

      render json: lesson_json(lesson)
    end

    private

    def lesson_json(lesson)
      origin = request.base_url
      {
        order:             lesson.order,
        slug:              lesson.slug,
        title:             lesson.title,
        description:       lesson.description,
        agentInstructions: lesson.agent_instructions_for(origin: origin),
        content:           lesson.body_for(origin: origin),
      }
    end
  end
end
