class CreateCodeExamples < ActiveRecord::Migration[7.1]
  def change
    create_table :code_examples do |t|
      t.string  :title, null: false
      t.text    :code
      t.integer :user_page_id

      t.timestamps
    end

    add_index :code_examples, :user_page_id
  end
end
