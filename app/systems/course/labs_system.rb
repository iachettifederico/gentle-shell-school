module Course
  # Entry point for reading labs and their starter files from any delivery channel.
  class LabsSystem
    def initialize(repository:)
      @repository = repository
    end

    def labs(locale: "en")
      catalog(locale).labs
    end

    delegate :files_for, to: :@repository

    def find_lab(slug, locale: "en")
      catalog(locale).find(slug)
    end

    def lab_for_lesson(slug, locale: "en")
      catalog(locale).for_lesson(slug)
    end

    private

    def catalog(locale)
      @catalogs ||= {}
      @catalogs[locale] ||= @repository.catalog(locale: locale)
    end
  end
end
