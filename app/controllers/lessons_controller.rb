class LessonsController < ApplicationController
  def show
    lesson = lessons_system.find_lesson(params[:slug])
    return render_not_found unless lesson

    render locals: lesson_locals(lesson)
  end

  private

  def render_not_found
    render "errors/not_found", status: :not_found
  end

  def lesson_locals(lesson)
    previous_lesson, next_lesson = lessons_system.lesson_neighbors(lesson.slug)
    lab = labs_system.lab_for_lesson(lesson.slug)
    {
      lesson: lesson, previous_lesson: previous_lesson, next_lesson: next_lesson,
      body_html: rendered_body(lesson), teach_me_prompt: teach_me_prompt(lesson),
      lab: lab, lab_brief_html: lab_brief_html(lab),
    }
  end

  def lab_brief_html(lab)
    MarkdownRenderer.new.render(lab.brief) if lab
  end

  def rendered_body(lesson)
    MarkdownRenderer.new.render(lesson.body_for(origin: request.base_url))
  end

  def teach_me_prompt(lesson)
    "Read #{request.base_url}/llms.txt and teach me the \"#{lesson.title}\" lesson (#{lesson.slug})."
  end
end
