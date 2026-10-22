module Course
  # Immutable proof that a lesson completion was checked.
  class Evidence
    VERIFIERS = %w[self independent-verifier].freeze
    RESULTS = %w[pass fail].freeze

    def initialize(value)
      raise InvalidEvidence unless valid_shape?(value)

      @checks = value.fetch("checks").map { |check| symbolize(check).freeze }.freeze
      @verified_by = value.fetch("verifiedBy").dup.freeze
    end

    def to_h
      { checks: @checks.map { |check| check.transform_values(&:dup) }, verifiedBy: @verified_by.dup }
    end

    private

    def valid_shape?(value)
      value.is_a?(Hash) && valid_evidence_keys?(value) && valid_checks?(value["checks"]) && valid_verifier?(value)
    end

    def valid_evidence_keys?(value)
      value.keys.sort == %w[checks verifiedBy]
    end

    def valid_verifier?(value)
      VERIFIERS.include?(value["verifiedBy"])
    end

    def valid_checks?(checks)
      checks.is_a?(Array) && checks.length.between?(1, 10) && checks.all? { |check| valid_check?(check) }
    end

    def valid_check?(check)
      check.is_a?(Hash) && valid_check_keys?(check) && valid_text?(check["command"]) &&
        valid_result?(check) && valid_text?(check["summary"])
    end

    def valid_check_keys?(check)
      check.keys.sort == %w[command result summary]
    end

    def valid_result?(check)
      RESULTS.include?(check["result"])
    end

    def valid_text?(value)
      value.is_a?(String) && !value.strip.empty? && value.length <= 500
    end

    def symbolize(check)
      {
        command: check.fetch("command").dup.freeze,
        result:  check.fetch("result").dup.freeze,
        summary: check.fetch("summary").dup.freeze,
      }
    end
  end

  class InvalidEvidence < StandardError
    def initialize
      super('Invalid "evidence" field')
    end
  end
end
