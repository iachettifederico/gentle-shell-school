class LessonsController < ApplicationController
  def show
    lesson = lessons_system.find_lesson(params[:slug], locale: @current_locale)
    return render_not_found unless lesson

    render locals: locale_context_locals.merge(lesson_locals(lesson))
  end

  private

  def render_not_found
    render "errors/not_found", status: :not_found, locals: locale_context_locals
  end

  def lesson_locals(lesson)
    previous_lesson, next_lesson = lessons_system.lesson_neighbors(lesson.slug, locale: @current_locale)
    lab = labs_system.lab_for_lesson(lesson.slug, locale: @current_locale)
    {
      lesson: lesson, previous_lesson: previous_lesson, next_lesson: next_lesson,
      body_html: rendered_body(lesson), lab: lab, lab_brief_html: lab_brief_html(lab),
    }.merge(prompt_locals(lesson, ""))
  end

  def lab_brief_html(lab)
    MarkdownRenderer.new.render(lab.brief) if lab
  end

  def rendered_body(lesson)
    MarkdownRenderer.new.render(lesson.body_for(origin: request.base_url))
  end
end
