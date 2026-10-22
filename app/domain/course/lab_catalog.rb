module Course
  # The lab set, addressed by either lab slug or its lesson.
  class LabCatalog
    def initialize(labs)
      @labs = labs.sort_by(&:slug).freeze
      reject_duplicates(:slug) do |slug|
        "duplicate lab slug #{slug.inspect}"
      end
      reject_duplicates(:lesson_slug) do |slug|
        "duplicate lab lesson #{slug.inspect}"
      end
    end

    def labs
      @labs
    end

    def find(slug)
      @labs.find { |lab| lab.slug == slug }
    end

    def for_lesson(slug)
      @labs.find { |lab| lab.lesson_slug == slug }
    end

    private

    def reject_duplicates(attribute)
      duplicate = @labs.map(&attribute).tally.find { |_value, count| count > 1 }
      raise InvalidLesson, yield(duplicate.first) if duplicate
    end
  end
end
