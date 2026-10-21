module Course
  # A public, anonymous identity for a student's course progress.
  class StudentId
    FORMAT = /\A[a-z]+-[a-z]+-\d{4}\z/
    ADJECTIVES = %w[curious bright patient eager clever kind].freeze
    NOUNS = %w[learner hacker maker explorer builder student].freeze

    def self.generate(random:)
      adjective = ADJECTIVES.fetch(random.rand(ADJECTIVES.length))
      noun = NOUNS.fetch(random.rand(NOUNS.length))
      "#{adjective}-#{noun}-#{random.rand(1000..9999)}"
    end

    def self.valid?(value)
      value.is_a?(String) && FORMAT.match?(value)
    end
  end
end
