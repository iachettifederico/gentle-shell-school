class HomeController < ApplicationController
  def index
    render locals: { lesson_groups: lessons_system.lesson_groups }
  end
end
