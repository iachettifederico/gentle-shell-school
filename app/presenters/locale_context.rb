class LocaleContext
  LANGUAGE_NAMES = {
    "en" => "English", "es" => "Español", "es-AR" => "Español (Argentina)",
  }.freeze

  def initialize(locale:, path:, routes:)
    @locale = locale
    @path = path
    @routes = routes
  end

  def locale
    @locale
  end

  def root_path
    @routes.root_path(locale: route_locale)
  end

  def lesson_path(slug)
    @routes.lesson_path(slug, locale: route_locale)
  end

  def enroll_path(code)
    @routes.enroll_path(code, locale: route_locale)
  end

  def switcher_entries
    LANGUAGE_NAMES.map { |locale, label| entry(locale, label) }
  end

  def alternates
    LANGUAGE_NAMES.keys.index_with { |locale| localized_path(locale) }
  end

  private

  def entry(locale, label)
    { locale: locale, label: label, path: localized_path(locale), current: locale == @locale }
  end

  def localized_path(locale)
    locale == "en" ? base_path : "/#{locale}#{base_path}"
  end

  def base_path
    @path.sub(%r{\A/(?:es|es-AR)(?=/|\z)}, "")
  end

  def route_locale
    @locale == "en" ? nil : @locale
  end
end
