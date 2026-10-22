require "tmpdir"

# Points the app at a temporary lessons directory for the duration of an example.
module LessonFixtures
  def with_lessons(files)
    Dir.mktmpdir do |dir|
      files.each do |name, content|
        File.write(File.join(dir, name), content)
      end
      original = Rails.configuration.x.lessons_directory
      Rails.configuration.x.lessons_directory = dir
      yield
    ensure
      Rails.configuration.x.lessons_directory = original
    end
  end

  def with_labs(labs, &)
    Dir.mktmpdir do |dir|
      write_labs(dir, labs)
      with_labs_directory(dir, &)
    end
  end

  def write_labs(directory, labs)
    labs.each { |slug, lab| write_lab(directory, slug, lab) }
  end

  def write_lab(directory, slug, lab)
    lab[:files].each do |path, content|
      write_lab_file(directory, slug, path, content)
    end
    File.write(File.join(directory, slug, "lab.yml"), lab[:metadata])
  end

  def write_lab_file(directory, slug, path, content)
    file = File.join(directory, slug, "starter", path)
    FileUtils.mkdir_p(File.dirname(file))
    File.write(file, content)
  end

  def with_labs_directory(directory, &)
    original = Rails.configuration.x.labs_directory
    Rails.configuration.x.labs_directory = directory
    yield
  ensure
    Rails.configuration.x.labs_directory = original
  end

  def lesson_markdown(slug:, order:, title:, body:, **options)
    <<~MD
      ---
      title: "#{title}"
      slug: #{slug}
      description: "About #{title.downcase}."
      order: #{order}
      quiz: #{options.fetch(:quiz, false)}
      #{module_frontmatter(options[:module_name])}agent_instructions: |
        Verify #{slug} at {origin}/lessons/#{slug}.
      ---

      #{body}
    MD
  end

  def module_frontmatter(module_name)
    "module: #{module_name}\n" if module_name
  end
end
