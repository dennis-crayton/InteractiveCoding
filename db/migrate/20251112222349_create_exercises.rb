class CreateExercises < ActiveRecord::Migration[7.1]
  def change
    create_table :exercises do |t|
      t.string  :title, null: false
      t.text    :prompt
      t.text    :starter_code
      t.integer :user_page_id

      t.timestamps
    end

    add_index :exercises, :user_page_id
  end
end
