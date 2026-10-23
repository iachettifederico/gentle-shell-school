class HomeController < ApplicationController
  def index
    lesson_groups = lessons_system.lesson_groups(locale: @current_locale)
    start_locals = prompt_locals(lesson_groups.values.flatten.first, "start_")
    render locals: locale_context_locals.merge(lesson_groups: lesson_groups, **start_locals)
  end
end
