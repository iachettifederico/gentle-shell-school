# Course lessons and labs are content files, not database rows.
demo_course = Rails.env.development? && ENV["COURSE"] == "demo"
Rails.application.config.x.lessons_directory = Rails.root.join(demo_course ? "content/demo/lessons" : "content/lessons")
Rails.application.config.x.labs_directory = Rails.root.join(demo_course ? "content/demo/labs" : "content/labs")
