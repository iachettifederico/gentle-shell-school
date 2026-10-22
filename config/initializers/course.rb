# Course lessons are Markdown files, not database rows.
Rails.application.config.x.lessons_directory = Rails.root.join(
  Rails.env.development? && ENV["COURSE"] == "demo" ? "content/demo/lessons" : "content/lessons"
)
