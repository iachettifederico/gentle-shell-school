module Course
  # Completion metadata retained for one lesson.
  class Completion
    def initialize(slug:, completed_at:, source:, model:)
      @slug = slug
      @completed_at = completed_at
      @source = source
      @model = model
    end

    def slug
      @slug
    end

    def completed_at
      @completed_at
    end

    def source
      @source
    end

    def model
      @model
    end
  end

  # The aggregate that owns a student's lesson completion lifecycle.
  class StudentProgress
    def initialize(created_at:, updated_at: nil, completions: [], student_id: nil)
      @student_id = student_id
      @created_at = created_at
      @updated_at = updated_at || created_at
      @completions = completions.dup
    end

    def student_id
      @student_id
    end

    def created_at
      @created_at
    end

    def updated_at
      @updated_at
    end

    def completions
      @completions.sort_by(&:completed_at).dup
    end

    def complete(slug, source:, model:, at:)
      unless completed?(slug)
        @completions << Completion.new(
          slug: slug, completed_at: at, source: completion_source(source), model: completion_model(model)
        )
      end
      @updated_at = at
    end

    def uncomplete(slug, at:)
      @completions.reject! do |completion|
        completion.slug == slug
      end
      @updated_at = at
    end

    def reset(at:)
      @completions = []
      @updated_at = at
    end

    private

    def completed?(slug)
      @completions.any? { |completion| completion.slug == slug }
    end

    def completion_source(source)
      source == "agent" ? "agent" : "browser"
    end

    def completion_model(model)
      value = model.to_s.strip
      value.empty? ? nil : value
    end
  end
end
