require "yaml"

module Course
  # Loads English source lessons and overlays a complete translated file when one
  # is available for the requested locale.
  class FileLessonRepository
    FRONTMATTER = /\A---\s*\n(?<yaml>.*?)\n---\s*\n(?<body>.*)\z/m
    KEYS = %w[title slug description order quiz module agent_instructions].freeze
    TRANSLATION_KEYS = %w[title description module].freeze

    def initialize(directory:)
      @directory = directory.to_s
    end

    def catalog(locale: "en")
      Catalog.new(lesson_paths.map { |path| load_lesson(path, locale: locale) })
    end

    private

    def lesson_paths
      Dir.glob(File.join(@directory, "*.md"))
    end

    def load_lesson(path, locale:)
      frontmatter, body = split(File.read(path))
      reject_unknown_keys(frontmatter, KEYS)
      translation, translated_body, served_locale = translated_content(path, locale)
      build_lesson(frontmatter, body, translation, translated_body, served_locale)
    rescue InvalidLesson => e
      raise InvalidLesson, "#{path}: #{e.message}"
    end

    def translated_content(path, locale)
      candidate = translated_candidate(path, locale)
      return [ {}, nil, "en" ] unless candidate

      load_translation(*candidate)
    end

    def translated_candidate(path, locale)
      Course::Locale.fallbacks_for(locale).each do |candidate|
        break if candidate == "en"

        path = File.join(@directory, candidate, File.basename(path))
        return [ path, candidate ] if File.file?(path)
      end
      nil
    end

    def load_translation(path, locale)
      frontmatter, body = split(File.read(path))
      reject_unknown_keys(frontmatter, TRANSLATION_KEYS)
      require_translation_keys(frontmatter)
      [ frontmatter, body.sub(/\A\s*\n/, ""), locale ]
    rescue InvalidLesson => e
      raise InvalidLesson, "#{path}: #{e.message}"
    end

    def build_lesson(frontmatter, body, translation, translated_body, locale)
      Lesson.new(
        metadata: lesson_metadata(frontmatter, translation), locale: locale,
        content: build_content(frontmatter, translation, translated_body || body.sub(/\A\s*\n/, ""))
      )
    end

    def lesson_metadata(frontmatter, translation)
      {
        slug: frontmatter["slug"], order: frontmatter["order"], quiz: frontmatter["quiz"],
        module_name: translation.fetch("module", frontmatter["module"]),
      }
    end

    def build_content(frontmatter, translation, body)
      LessonContent.new(
        title: translation.fetch("title", frontmatter["title"]),
        description: translation.fetch("description", frontmatter["description"]),
        agent_instructions: frontmatter["agent_instructions"], body: body
      )
    end

    def require_translation_keys(frontmatter)
      missing = TRANSLATION_KEYS - frontmatter.keys
      raise InvalidLesson, "missing translation keys: #{missing.join(', ')}" if missing.any?
    end

    def reject_unknown_keys(frontmatter, keys)
      unknown = frontmatter.keys - keys
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
