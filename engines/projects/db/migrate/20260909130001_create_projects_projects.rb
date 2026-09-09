class CreateProjectsProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects_projects do |t|
      t.string :name, null: false
      # The tag is the project. Unique across the whole tree rather than
      # among siblings: a tag means one thing wherever it is written, and two
      # projects keyed to "#print" would put the same work in two places.
      t.string :tag, null: false, index: { unique: true }
      t.text :note
      t.references :parent, foreign_key: { to_table: :projects_projects }

      t.timestamps
    end
  end
end
