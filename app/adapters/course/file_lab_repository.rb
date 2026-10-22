require "yaml"

module Course
  # Loads lab metadata and starter files from the course content directory.
  class FileLabRepository
    KEYS = %w[slug lesson title brief check rubric].freeze
    TRANSLATION_KEYS = %w[title brief].freeze

    def initialize(directory:)
      @directory = directory.to_s
    end

    def catalog(locale: "en")
      LabCatalog.new(lab_paths.map { |path| load_lab(path, locale: locale) })
    end

    def files_for(slug)
      starter_paths(slug).map { |path| file_json(slug, path) }
    end

    private

    def lab_paths
      Dir.glob(File.join(@directory, "*", "lab.yml"))
    end

    def load_lab(path, locale:)
      frontmatter = YAML.safe_load_file(path)
      reject_invalid_frontmatter(frontmatter)
      translation, served_locale = translated_content(path, locale)
      Lab.new(**attributes_for(frontmatter, translation, served_locale))
    rescue InvalidLesson => e
      raise InvalidLesson, "#{path}: #{e.message}"
    rescue Psych::SyntaxError => e
      raise InvalidLesson, "#{path}: invalid YAML (#{e.problem})"
    end

    def translated_content(path, locale)
      candidate = translated_candidate(path, locale)
      return [ {}, "en" ] unless candidate

      load_translation(*candidate)
    end

    def translated_candidate(path, locale)
      Course::Locale.fallbacks_for(locale).each do |locale|
        break if locale == "en"

        path = File.join(File.dirname(path), "i18n", "#{locale}.yml")
        return [ path, locale ] if File.file?(path)
      end
      nil
    end

    def load_translation(path, locale)
      translation = YAML.safe_load_file(path)
      validate_translation(translation)
      [ translation, locale ]
    rescue Psych::SyntaxError => e
      raise InvalidLesson, "#{path}: invalid YAML (#{e.problem})"
    end

    def validate_translation(translation)
      raise InvalidLesson, "translation must be a YAML mapping" unless translation.is_a?(Hash)

      reject_unknown_translation_keys(translation)
      require_translation_keys(translation)
    end

    def reject_unknown_translation_keys(translation)
      unknown = translation.keys - TRANSLATION_KEYS
      raise InvalidLesson, "unknown translation keys: #{unknown.join(', ')}" if unknown.any?
    end

    def require_translation_keys(translation)
      missing = TRANSLATION_KEYS - translation.keys
      raise InvalidLesson, "missing translation keys: #{missing.join(', ')}" if missing.any?
    end

    def reject_invalid_frontmatter(frontmatter)
      raise InvalidLesson, "lab.yml must be a YAML mapping" unless frontmatter.is_a?(Hash)

      unknown = frontmatter.keys - KEYS
      raise InvalidLesson, "unknown lab keys: #{unknown.join(', ')}" if unknown.any?
    end

    def attributes_for(frontmatter, translation, locale)
      {
        slug: frontmatter["slug"], lesson_slug: frontmatter["lesson"],
        title: translation.fetch("title", frontmatter["title"]),
        brief: translation.fetch("brief", frontmatter["brief"]), check: frontmatter["check"],
        rubric: frontmatter["rubric"], locale: locale,
      }
    end

    def starter_paths(slug)
      starter = File.join(@directory, slug, "starter")
      return [] unless File.directory?(starter)

      root = File.realpath(starter)
      Dir.glob(File.join(root, "**", "*")).select { |path| servable?(root, path) }.sort
    end

    def servable?(root, path)
      !File.symlink?(path) && File.file?(path) && File.realpath(path).start_with?("#{root}/")
    end

    def file_json(slug, path)
      starter = File.realpath(File.join(@directory, slug, "starter"))
      { path: path.delete_prefix("#{starter}/"), content: File.read(path) }
    end
  end
end
