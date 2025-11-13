namespace :setup do
  desc "Setup the application for first-time use"
  task :first_time do
    puts "\n=========================================="
    puts "Interactive Coding - First Time Setup"
    puts "==========================================\n"
    
    puts "Installing dependencies..."
    system("bundle install") || abort("Bundle install failed")
    
    puts "\nSetting up database..."
    Rake::Task["db:setup"].invoke
    
    puts "\nPulling Docker images..."
    images = [
      "ruby:3.3-alpine",
      "python:3.11-alpine",
      "openjdk:17-alpine"
    ]
    
    images.each do |image|
      puts "  Pulling #{image}..."
      system("docker pull #{image}")
    end
    
    puts "\nSetup complete!"
    puts "\nTo start the server, run:"
    puts "  rails server"
    puts "\nThen visit: http://localhost:3000\n\n"
  end
  
  desc "Pull all Docker images"
  task :docker_images do
    images = [
      "ruby:3.3-alpine",
      "python:3.11-alpine", 
      "openjdk:17-alpine",
      "php:8.2-alpine",
      "perl:5.38-slim"
    ]
    
    puts "Pulling Docker images..."
    images.each do |image|
      puts "  #{image}..."
      system("docker pull #{image}")
    end
    puts "Done!"
  end
end