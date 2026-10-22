module Course
  # A hands-on exercise linked to one course lesson.
  class Lab
    ATTRIBUTES = %i[slug lesson_slug title brief check rubric].freeze

    def initialize(**attributes)
      ATTRIBUTES.each do |attribute|
        instance_variable_set("@#{attribute}", attributes[attribute])
      end
      validate
      @rubric = @rubric.freeze
    end

    ATTRIBUTES.each do |attribute|
      define_method(attribute) { instance_variable_get("@#{attribute}") }
    end

    private

    def validate
      validate_strings
      validate_rubric
    end

    def validate_strings
      ATTRIBUTES.reject { |attribute| attribute == :rubric }.each do |attribute|
        valid = public_send(attribute).is_a?(String) && public_send(attribute).match?(/\S/)
        raise InvalidLesson, "lab #{attribute.to_s.tr('_', ' ')} must be present" unless valid
      end
    end

    def validate_rubric
      valid = @rubric.is_a?(Array) && @rubric.all? { |item| item.is_a?(String) && item.match?(/\S/) }
      raise InvalidLesson, "lab rubric must contain strings" unless valid
    end
  end
end
