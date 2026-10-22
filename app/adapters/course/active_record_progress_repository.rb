module Course
  # Maps the Rails persistence records to the framework-free progress aggregate.
  class ActiveRecordProgressRepository
    def create(progress)
      student = insert_student(progress)
      progress.completions.each do |completion|
        save_completion(student, completion)
      end
      hydrate(student)
    end

    def find(student_id)
      student = Student.includes(:lesson_completions).find_by(public_id: student_id)
      hydrate(student) if student
    end

    def save(progress)
      student = Student.find_by!(public_id: progress.student_id)
      student.update!(updated_at: progress.updated_at)
      student.lesson_completions.destroy_all
      progress.completions.each do |completion|
        save_completion(student, completion)
      end
      hydrate(student)
    end

    def transaction(&)
      ApplicationRecord.transaction(&)
    end

    private

    def insert_student(progress)
      Student.create!(public_id: progress.student_id, created_at: progress.created_at, updated_at: progress.updated_at)
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
      raise StudentIdTaken, e.message if Student.exists?(public_id: progress.student_id)

      raise
    end

    def hydrate(student)
      StudentProgress.new(
        student_id:  student.public_id,
        created_at:  student.created_at,
        updated_at:  student.updated_at,
        completions: student.lesson_completions.map { |completion| hydrate_completion(completion) }
      )
    end

    def hydrate_completion(completion)
      Completion.new(
        slug:         completion.lesson_slug,
        completed_at: completion.completed_at,
        source:       completion.source,
        model:        completion.model,
        evidence:     completion.evidence && Evidence.new(completion.evidence)
      )
    end

    def save_completion(student, completion)
      student.lesson_completions.create!(
        lesson_slug:  completion.slug,
        completed_at: completion.completed_at,
        source:       completion.source,
        model:        completion.model,
        evidence:     completion.evidence&.to_h
      )
    end
  end
end
