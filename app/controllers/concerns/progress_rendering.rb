# Converts progress facade results to the public API representation.
module ProgressRendering
  private

  def progress_json(progress)
    {
      completedLessons: progress.completions.map { |completion| completion_json(completion) },
      createdAt:        progress.created_at.iso8601,
      updatedAt:        progress.updated_at.iso8601,
    }
  end

  def completion_json(completion)
    {
      slug:        completion.slug,
      completedAt: completion.completed_at.iso8601,
      source:      completion.source,
      **(completion.model ? { model: completion.model } : {}),
    }
  end
end
