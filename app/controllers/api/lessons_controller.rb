module Api
  class LessonsController < BaseController
    def index
      render json: lessons_system.lessons(locale: requested_locale).map { |lesson| lesson_json(lesson) }
    end

    def show
      lesson = lessons_system.find_lesson(params[:slug], locale: requested_locale)
      return render json: { error: "Lesson not found" }, status: :not_found unless lesson

      render json: lesson_json(lesson)
    end

    private

    def lesson_json(lesson)
      lesson_fields(lesson).merge(resolved_lesson_fields(lesson, request.base_url), lesson_links(lesson))
    end

    def lesson_links(lesson)
      _previous, following = lessons_system.lesson_neighbors(lesson.slug, locale: requested_locale)
      { url: lesson_page_url(lesson), next: following && next_lesson_json(following) }
    end

    def next_lesson_json(lesson)
      { slug: lesson.slug, title: lesson.title, url: lesson_page_url(lesson), prompt: lesson_prompt.for(lesson) }
    end

    def lesson_page_url(lesson)
      lesson_url(lesson.slug, locale: requested_locale == "en" ? nil : requested_locale)
    end

    def lesson_prompt
      @lesson_prompt ||= LessonPrompt.new(origin: request.base_url, locale: requested_locale)
    end

    def lesson_fields(lesson)
      {
        order: lesson.order, slug: lesson.slug, title: lesson.title, description: lesson.description,
        module: lesson.module_name, lab: labs_system.lab_for_lesson(lesson.slug, locale: requested_locale)&.slug,
        locale: lesson.locale,
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
