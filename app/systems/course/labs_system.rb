require "active_support/core_ext/module/delegation"

module Course
  # Entry point for reading labs and their starter files from any delivery channel.
  class LabsSystem
    def initialize(repository:)
      @repository = repository
    end

    delegate :labs, to: :catalog
    delegate :files_for, to: :repository

    def find_lab(slug)
      catalog.find(slug)
    end

    def lab_for_lesson(slug)
      catalog.for_lesson(slug)
    end

    private

    attr_reader :repository

    def catalog
      @catalog ||= repository.catalog
    end
  end
end
