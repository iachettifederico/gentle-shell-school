module Course
  class UnknownLesson < StandardError
    def initialize(slug)
      super("Unknown lesson slug: #{slug.inspect}")
    end
  end
end
