class CreateCourseProgress < ActiveRecord::Migration[8.2]
  def change
    create_table :students do |t|
      t.string :public_id, null: false
      t.timestamps
    end
    add_index :students, :public_id, unique: true

    create_table :lesson_completions do |t|
      t.references :student, null: false, foreign_key: true
      t.string :lesson_slug, null: false
      t.datetime :completed_at, null: false
      t.string :source, null: false
      t.string :model
    end
    add_index :lesson_completions, [ :student_id, :lesson_slug ], unique: true
  end
end
