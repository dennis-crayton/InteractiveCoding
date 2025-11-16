class AddAccentColorToUserPages < ActiveRecord::Migration[8.0]
  def change
    add_column :user_pages, :accent_color, :string
  end
end
