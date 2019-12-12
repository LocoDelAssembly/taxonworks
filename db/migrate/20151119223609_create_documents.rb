class CreateDocuments < ActiveRecord::Migration[4.2]

  def change
    create_table :documents do |t|
      t.attachment :document_file, null: false, index: true
      t.references :project, null: false
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false

      t.timestamps null: false
    end

    add_foreign_key :documents, :users, column: :created_by_id
    add_foreign_key :documents, :users, column: :updated_by_id
  end

end
