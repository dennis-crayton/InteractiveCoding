class CreateTutorials < ActiveRecord::Migration[8.0]
  def change
    create_table :tutorials do |t|
      t.string :title
      t.text :description
      t.integer :user_id

      t.timestamps
    end
  end
end
