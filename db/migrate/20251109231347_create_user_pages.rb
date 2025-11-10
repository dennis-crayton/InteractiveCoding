class CreateUserPages < ActiveRecord::Migration[8.0]
  def change
    create_table :user_pages do |t|
      t.string :title
      t.string :language
      t.string :author
      t.text :description
      t.text :content
      t.integer :downloads

      t.timestamps
    end
  end
end
