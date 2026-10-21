module Course
  # The ordered set of lessons. Slugs and orders are unique across the course.
  class Catalog
    def initialize(lessons)
      @lessons = lessons.sort_by(&:order).freeze
      reject_duplicates(:slug) do |slug|
        "duplicate lesson slug #{slug.inspect}"
      end
      reject_duplicates(:order) { |order| "duplicate lesson order #{order}" }
    end

    def lessons
      @lessons
    end

    def find(slug)
      @lessons.find { |lesson| lesson.slug == slug }
    end

    private

    def reject_duplicates(attribute)
      duplicate = @lessons.map(&attribute).tally.find { |_value, count| count > 1 }
      raise InvalidLesson, yield(duplicate.first) if duplicate
    end
  end
end
