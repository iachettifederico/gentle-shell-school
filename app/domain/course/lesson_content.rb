module Course
  # The authored text of a lesson. Text may reference the serving site through
  # an {origin} placeholder, resolved when the lesson is served.
  class LessonContent
    ORIGIN_PLACEHOLDER = "{origin}".freeze

    def initialize(title:, description:, agent_instructions:, body:)
      @title = require_present(:title, title)
      @description = require_present(:description, description)
      @agent_instructions = require_present(:agent_instructions, agent_instructions)
      @body = body.to_s
    end

    def title
      @title
    end

    def description
      @description
    end

    def agent_instructions_for(origin:, appendix: nil)
      instructions = appendix ? "#{@agent_instructions}\n\n#{appendix}" : @agent_instructions
      resolve(instructions, origin)
    end

    def body_for(origin:)
      resolve(@body, origin)
    end

    private

    def resolve(text, origin)
      text.gsub(ORIGIN_PLACEHOLDER, origin)
    end

    def require_present(field, value)
      text = value.to_s.strip
      raise InvalidLesson, "lesson #{field} must be present" if text.empty?

      text
    end
  end
end
