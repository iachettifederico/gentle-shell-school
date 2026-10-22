require "digest"

module Course
  # Persists pending enrollment state and supplies row locking for claims.
  class ActiveRecordEnrollmentRepository
    def create(enrollment)
      ::PendingEnrollment.create!(record_attributes(enrollment))
      enrollment
    end

    def find(code)
      record = ::PendingEnrollment.find_by(code_digest: digest_for(code))
      hydrate(record, code: code) if record
    end

    def find_for_claim(code)
      record = ::PendingEnrollment.lock.find_by(code_digest: digest_for(code))
      hydrate(record, code: code) if record
    end

    def save(enrollment)
      record = ::PendingEnrollment.find_by!(code_digest: digest_for(enrollment.code))
      record.update!(record_attributes(enrollment))
      enrollment
    end

    def transaction(&)
      ApplicationRecord.transaction(&)
    end

    private

    def record_attributes(enrollment)
      { code_digest: digest_for(enrollment.code), status: enrollment.status, expires_at: enrollment.expires_at,
        student_id: student_database_id(enrollment), created_at: enrollment.created_at,
        updated_at: enrollment.created_at, }
    end

    def student_database_id(enrollment)
      return unless enrollment.claimed_student_id

      Student.find_by!(public_id: enrollment.claimed_student_id).id
    end

    def hydrate(record, code:)
      Course::PendingEnrollment.new(code: code, created_at: record.created_at, expires_at: record.expires_at,
                                    status: record.status, claimed_student_id: record.student&.public_id)
    end

    def digest_for(code)
      Digest::SHA256.hexdigest(code)
    end
  end
end
