module Course
  # Application entry point for anonymous enrollment and lesson progress.
  class ProgressSystem
    ENROLLMENT_ATTEMPTS = 10

    def initialize(repository:, lessons_system:, id_generator: StudentId, clock: -> { Time.now.utc })
      @repository = repository
      @lessons_system = lessons_system
      @id_generator = id_generator
      @clock = clock
    end

    def enroll
      ENROLLMENT_ATTEMPTS.times do
        progress = StudentProgress.new(student_id: next_student_id, created_at: now)
        return @repository.create(progress)
      rescue StudentIdTaken
        next
      end
      raise EnrollmentFailed, "Could not generate a unique student ID after #{ENROLLMENT_ATTEMPTS} attempts"
    end

    def progress_for(student_id)
      find_progress(student_id)
    end

    def complete_lesson(student_id, lesson_slug:, source:, model:)
      update_known_lesson(student_id, lesson_slug) do |progress|
        progress.complete(lesson_slug, source: source, model: model, at: now)
      end
    end

    def uncomplete_lesson(student_id, lesson_slug:)
      update_known_lesson(student_id, lesson_slug) do |progress|
        progress.uncomplete(lesson_slug, at: now)
      end
    end

    def reset(student_id)
      @repository.transaction do
        progress = find_progress(student_id)
        progress.reset(at: now)
        @repository.save(progress)
      end
    end

    private

    def update_known_lesson(student_id, lesson_slug)
      @repository.transaction do
        progress = find_progress(student_id)
        raise UnknownLesson, lesson_slug unless @lessons_system.find_lesson(lesson_slug)

        yield(progress)
        @repository.save(progress)
      end
    end

    def find_progress(student_id)
      raise InvalidStudentId unless StudentId.valid?(student_id)

      @repository.find(student_id) || raise(StudentNotFound)
    end

    def next_student_id
      @id_generator.generate(random: Random)
    end

    def now
      @clock.call
    end
  end
end
