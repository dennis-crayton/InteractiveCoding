class CreateSections < ActiveRecord::Migration[7.1]
  def change
    create_table :sections do |t|
      t.string  :title, null: false
      t.text    :content
      t.integer :user_page_id

      t.timestamps
    end

    add_index :sections, :user_page_id
  end
end
