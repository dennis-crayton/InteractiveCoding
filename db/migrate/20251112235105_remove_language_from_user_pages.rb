class RemoveLanguageFromUserPages < ActiveRecord::Migration[8.0]
  def change
    remove_column :user_pages, :language, :string
  end
end
