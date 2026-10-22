module Course
  class Locale
    AVAILABLE = %w[en es es-AR].freeze
    WEBSITE = %w[es es-AR].freeze

    def self.valid?(value)
      AVAILABLE.include?(value.to_s)
    end

    def self.fallbacks_for(value)
      case value.to_s
      when "en" then [ "en" ]
      when "es" then %w[es en]
      when "es-AR" then %w[es-AR es en]
      else []
      end
    end
  end
end
