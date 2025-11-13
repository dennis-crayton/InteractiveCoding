class CreateUserPages < ActiveRecord::Migration[7.1]
  def change
    create_table :user_pages do |t|
      t.string  :title, null: false
      t.string  :author
      t.text    :description
      t.string  :accent_color
      t.integer :language_id

      t.timestamps
    end

    add_index :user_pages, :language_id
  end
end
