require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GentleShellSchool
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1
    config.autoload_paths << Rails.root.join("app/domain")
    config.eager_load_paths << Rails.root.join("app/domain")
    config.autoload_paths << Rails.root.join("app/adapters")
    config.eager_load_paths << Rails.root.join("app/adapters")
    config.autoload_paths << Rails.root.join("app/systems")
    config.eager_load_paths << Rails.root.join("app/systems")

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks rubocop])

    # Course lessons are Markdown files, not database rows.
    config.x.lessons_directory = Rails.root.join("content/lessons")

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
