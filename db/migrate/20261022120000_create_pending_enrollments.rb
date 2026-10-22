class CreatePendingEnrollments < ActiveRecord::Migration[8.2]
  def change
    create_table :pending_enrollments do |t|
      t.string :code, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :expires_at, null: false
      t.references :student, null: true, foreign_key: true
      t.timestamps
    end

    add_index :pending_enrollments, :code, unique: true
  end
end
