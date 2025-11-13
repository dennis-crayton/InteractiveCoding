class AddLanguageIdToUserPages < ActiveRecord::Migration[8.0]
  def change
    add_column :user_pages, :language_id, :integer
    add_index :user_pages, :language_id
  end
end
