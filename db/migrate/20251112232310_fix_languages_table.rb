class FixLanguagesTable < ActiveRecord::Migration[7.1]
  def change
    # Remove the wrong column
    remove_column :languages, :version, :string

    # Add the correct columns
    add_column :languages, :extension, :string
    add_column :languages, :command, :string
  end
end
