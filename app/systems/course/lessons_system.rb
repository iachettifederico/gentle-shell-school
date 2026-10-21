module Course
  # Entry point for reading course lessons from any delivery channel.
  class LessonsSystem
    def initialize(repository:)
      @repository = repository
    end

    delegate :lessons, to: :catalog

    def find_lesson(slug)
      catalog.find(slug)
    end

    private

    def catalog
      @catalog ||= @repository.catalog
    end
  end
end
