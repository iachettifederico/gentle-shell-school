require "yaml"

module Course
  # Loads lessons from Markdown files with YAML frontmatter:
  #
  #   ---
  #   title: "Welcome"
  #   slug: welcome
  #   description: "Meet the course."
  #   order: 1
  #   quiz: false
  #   agent_instructions: |
  #     What "done" looks like and how to verify it.
  #   ---
  #   Markdown body...
  class FileLessonRepository
    FRONTMATTER = /\A---\s*\n(?<yaml>.*?)\n---\s*\n(?<body>.*)\z/m
    KEYS = %w[title slug description order quiz module agent_instructions].freeze

    def initialize(directory:)
      @directory = directory.to_s
    end

    def catalog
      Catalog.new(lesson_paths.map { |path| load_lesson(path) })
    end

    private

    def lesson_paths
      Dir.glob(File.join(@directory, "*.md"))
    end

    def load_lesson(path)
      frontmatter, body = split(File.read(path))
      reject_unknown_keys(frontmatter)
      build_lesson(frontmatter, body)
    rescue InvalidLesson => e
      raise InvalidLesson, "#{path}: #{e.message}"
    end

    def build_lesson(frontmatter, body)
      Lesson.new(
        slug:        frontmatter["slug"],
        order:       frontmatter["order"],
        quiz:        frontmatter["quiz"],
        module_name: frontmatter["module"],
        content:     build_content(frontmatter, body)
      )
    end

    def build_content(frontmatter, body)
      LessonContent.new(
        title:              frontmatter["title"],
        description:        frontmatter["description"],
        agent_instructions: frontmatter["agent_instructions"],
        body:               body.sub(/\A\s*\n/, "")
      )
    end

    def reject_unknown_keys(frontmatter)
      unknown = frontmatter.keys - KEYS
      raise InvalidLesson, "unknown frontmatter keys: #{unknown.join(', ')}" if unknown.any?
    end

    def split(content)
      match = FRONTMATTER.match(content)
      raise InvalidLesson, "missing YAML frontmatter" unless match

      frontmatter = YAML.safe_load(match[:yaml])
      raise InvalidLesson, "frontmatter must be a YAML mapping" unless frontmatter.is_a?(Hash)

      [ frontmatter, match[:body] ]
    rescue Psych::SyntaxError => e
      raise InvalidLesson, "invalid YAML frontmatter (#{e.problem})"
    end
  end
end
