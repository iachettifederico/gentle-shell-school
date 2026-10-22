module Course
  # Entry point for reading course lessons from any delivery channel.
  class LessonsSystem
    def initialize(repository:)
      @repository = repository
    end

    def lessons(locale: "en")
      catalog(locale).lessons
    end

    def find_lesson(slug, locale: "en")
      catalog(locale).find(slug)
    end

    def lesson_neighbors(slug, locale: "en")
      catalog(locale).neighbors_for(slug)
    end

    def lesson_groups(locale: "en")
      lessons(locale: locale).group_by(&:module_name)
    end

    private

    def catalog(locale)
      @catalogs ||= {}
      @catalogs[locale] ||= @repository.catalog(locale: locale)
    end
  end
end
