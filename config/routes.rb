Rails.application.routes.draw do
  # Root path (home page)
  root "home#index"

  # Language pages
  get "/languages/ruby", to: "languages#ruby"
  get "/languages/python", to: "languages#python"
  get "/languages/java", to: "languages#java"

  # Code execution endpoint
  post "/code/run", to: "code#run"

  # Health check (optional, but useful)
  get "up" => "rails/health#show", as: :rails_health_check
end