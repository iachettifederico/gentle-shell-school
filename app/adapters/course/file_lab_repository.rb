require "yaml"

module Course
  # Loads lab metadata and starter files from the course content directory.
  class FileLabRepository
    KEYS = %w[slug lesson title brief check rubric].freeze

    def initialize(directory:)
      @directory = directory.to_s
    end

    def catalog
      LabCatalog.new(lab_paths.map { |path| load_lab(path) })
    end

    def files_for(slug)
      starter_paths(slug).map { |path| file_json(slug, path) }
    end

    private

    def lab_paths
      Dir.glob(File.join(@directory, "*", "lab.yml"))
    end

    def load_lab(path)
      frontmatter = YAML.safe_load_file(path)
      reject_invalid_frontmatter(frontmatter)
      Lab.new(**attributes_for(frontmatter))
    rescue InvalidLesson => e
      raise InvalidLesson, "#{path}: #{e.message}"
    rescue Psych::SyntaxError => e
      raise InvalidLesson, "#{path}: invalid YAML (#{e.problem})"
    end

    def reject_invalid_frontmatter(frontmatter)
      raise InvalidLesson, "lab.yml must be a YAML mapping" unless frontmatter.is_a?(Hash)

      unknown = frontmatter.keys - KEYS
      raise InvalidLesson, "unknown lab keys: #{unknown.join(', ')}" if unknown.any?
    end

    def attributes_for(frontmatter)
      {
        slug: frontmatter["slug"], lesson_slug: frontmatter["lesson"], title: frontmatter["title"],
        brief: frontmatter["brief"], check: frontmatter["check"], rubric: frontmatter["rubric"],
      }
    end

    def starter_paths(slug)
      Dir.glob(File.join(@directory, slug, "starter", "**", "*")).select { |path| File.file?(path) }.sort
    end

    def file_json(slug, path)
      starter = File.join(@directory, slug, "starter")
      { path: path.delete_prefix("#{starter}/"), content: File.read(path) }
    end
  end
end
