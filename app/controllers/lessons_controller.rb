class LessonsController < ApplicationController
  def show
    lesson = lessons_system.find_lesson(params[:slug])
    raise ActionController::RoutingError, "Lesson not found" unless lesson

    body_html = MarkdownRenderer.new.render(lesson.body_for(origin: request.base_url))
    render locals: { lesson: lesson, body_html: body_html }
  end
end
