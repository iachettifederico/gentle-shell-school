module Course
  # Persists pending enrollment state and supplies row locking for claims.
  class ActiveRecordEnrollmentRepository
    def create(enrollment)
      hydrate(::PendingEnrollment.create!(record_attributes(enrollment)))
    end

    def find(code)
      record = ::PendingEnrollment.find_by(code: code)
      hydrate(record) if record
    end

    def find_for_claim(code)
      record = ::PendingEnrollment.lock.find_by(code: code)
      hydrate(record) if record
    end

    def save(enrollment)
      record = ::PendingEnrollment.find_by!(code: enrollment.code)
      record.update!(record_attributes(enrollment))
      hydrate(record)
    end

    def transaction(&)
      ApplicationRecord.transaction(&)
    end

    private

    def record_attributes(enrollment)
      { code: enrollment.code, status: enrollment.status, expires_at: enrollment.expires_at,
        student_id: student_database_id(enrollment), created_at: enrollment.created_at,
        updated_at: enrollment.created_at, }
    end

    def student_database_id(enrollment)
      return unless enrollment.claimed_student_id

      Student.find_by!(public_id: enrollment.claimed_student_id).id
    end

    def hydrate(record)
      Course::PendingEnrollment.new(code: record.code, created_at: record.created_at, expires_at: record.expires_at,
                                    status: record.status, claimed_student_id: record.student&.public_id)
    end
  end
end
