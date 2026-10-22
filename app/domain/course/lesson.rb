require "forwardable"

module Course
  # One lesson of the course: where it sits, whether it ends in a quiz, and its
  # authored content.
  class Lesson
    extend Forwardable

    def_delegators :@content, :title, :description, :body_for

    SLUG_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

    def initialize(metadata:, content:, locale: "en")
      @slug = require_slug(metadata[:slug])
      @order = require_positive_integer(metadata[:order])
      @quiz = require_boolean(metadata[:quiz])
      @module_name = metadata[:module_name]
      @content = content
      @locale = locale
    end

    def slug
      @slug
    end

    def order
      @order
    end

    def quiz?
      @quiz
    end

    def module_name
      @module_name
    end

    def locale
      @locale
    end

    # Instructions for the student's agent, resolved for the origin serving them.
    # Quiz lessons get the shared quiz boilerplate appended.
    def agent_instructions_for(origin:)
      @content.agent_instructions_for(origin: origin, appendix: (QuizInstructions::TEXT if quiz?))
    end

    private

    def require_slug(slug)
      text = slug.to_s.strip
      raise InvalidLesson, "lesson slug must be present" if text.empty?
      raise InvalidLesson, "lesson slug #{text.inspect} must be lowercase kebab-case" unless SLUG_FORMAT.match?(text)

      text
    end

    def require_positive_integer(order)
      return order if order.is_a?(Integer) && order.positive?

      raise InvalidLesson, "lesson #{@slug.inspect}: order must be a positive integer, got #{order.inspect}"
    end

    def require_boolean(quiz)
      return quiz if [ true, false ].include?(quiz)

      raise InvalidLesson, "lesson #{@slug.inspect}: quiz must be true or false, got #{quiz.inspect}"
    end
  end
end
