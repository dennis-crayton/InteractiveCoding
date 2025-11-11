Rails.application.routes.draw do
  # Root path (home page)
  root "home#index"

  #Sandbox pages
  # get "/sandbox/python", to: "sandbox#python", as: :sandbox_python
  # get "/sandbox/ruby", to: "sandbox#ruby", as: :sandbox_ruby  
  # get "/sandbox/java", to: "sandbox#java", as: :sandbox_java
  
  #Sandbox pages 
  get "/languages/ruby/sandbox", to: "sandbox#ruby", as: :languages_ruby_sandbox
  get "/languages/python/sandbox", to: "sandbox#python", as: :languages_python_sandbox
  get "/languages/java/sandbox", to: "sandbox#java", as: :languages_java_sandbox

  #Language pages
  get "/languages/ruby", to: "languages#ruby"
  get "/languages/python", to: "languages#python"
  get "/languages/java", to: "languages#java"

  # Code execution endpoint
  post "/code/run", to: "code#run"

  # Health check (optional, but useful)
  get "up" => "rails/health#show", as: :rails_health_check
end