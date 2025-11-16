# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
# db/seeds.rb
# Ensure existence of languages required to run the application in all environments.
# This is idempotent and can be executed multiple times with bin/rails db:seed

interpreted_languages = [
  { name: "ruby",       image: "ruby:3.3-alpine",       extension: ".rb",  command: "ruby" },
  { name: "python",     image: "python:3.12-alpine",   extension: ".py",  command: "python3" },
  { name: "javascript", image: "node:22-alpine",       extension: ".js",  command: "node" },
  { name: "perl",       image: "perl:5.38-slim",     extension: ".pl",  command: "perl" },
  { name: "php",        image: "php:8.2-cli-alpine",   extension: ".php", command: "php" },
  { name: "bash",       image: "bash:5.2-alpine",      extension: ".sh",  command: "bash" }
]

interpreted_languages.each do |lang|
  Language.find_or_create_by!(name: lang[:name]) do |l|
    l.image     = lang[:image]
    l.extension = lang[:extension]
    l.command   = lang[:command]
  end
end

puts "✅ Interpreted languages seeded successfully!"