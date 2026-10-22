class AddEvidenceToLessonCompletions < ActiveRecord::Migration[8.2]
  def change
    add_column :lesson_completions, :evidence, :json
  end
end
