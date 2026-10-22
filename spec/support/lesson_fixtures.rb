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
