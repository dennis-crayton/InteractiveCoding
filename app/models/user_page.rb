# app/models/user_page.rb
class UserPage < ApplicationRecord
  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :language, presence: true
  validates :author, presence: true, length: { minimum: 2, maximum: 50 }
  validates :description, presence: true, length: { minimum: 10, maximum: 500 }
  validates :content, presence: true, length: { minimum: 50 }
  
  # Default value for downloads
  before_create :set_default_downloads
  
  # Increment download count
  def increment_downloads!
    update(downloads: downloads + 1)
  end
  
  # Export to JSON format for download
  def to_export
    {
      title: title,
      language: language,
      author: author,
      description: description,
      content: content,
      exported_at: Time.now.iso8601
    }
  end
  
  # Import from JSON
  def self.from_export(json_data)
    new(
      title: json_data["title"],
      language: json_data["language"],
      author: json_data["author"],
      description: json_data["description"],
      content: json_data["content"],
      downloads: 0
    )
  end
  
  def parsed_content
    JSON.parse(content || '{}')
  rescue JSON::ParserError
    {}
  end
  
  private
  
  def set_default_downloads
    self.downloads ||= 0
  end
end