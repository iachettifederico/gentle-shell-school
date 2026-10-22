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
      lesson_fields(lesson).merge(resolved_lesson_fields(lesson, request.base_url))
    end

    def lesson_fields(lesson)
      {
        order: lesson.order, slug: lesson.slug, title: lesson.title, description: lesson.description,
        module: lesson.module_name, lab: labs_system.lab_for_lesson(lesson.slug)&.slug,
      }
    end

    def resolved_lesson_fields(lesson, origin)
      { agentInstructions: lesson.agent_instructions_for(origin: origin), content: lesson.body_for(origin: origin) }
    end

    def labs_system
      @labs_system ||= Course::LabsSystem.new(
        repository: Course::FileLabRepository.new(directory: Rails.configuration.x.labs_directory)
      )
    end
  end
end
