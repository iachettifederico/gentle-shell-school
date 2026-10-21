class HomeController < ApplicationController
  def index
    render locals: { lessons: lessons_system.lessons }
  end
end
