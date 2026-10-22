class HomeController < ApplicationController
  def index
    render locals: locale_context_locals.merge(lesson_groups: lessons_system.lesson_groups(locale: @current_locale))
  end
end
