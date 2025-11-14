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

  # User-created pages
  get "/user_pages", to: "user_pages#index", as: :user_pages
  get "/user_pages/new", to: "user_pages#new", as: :new_user_page
  post "/user_pages", to: "user_pages#create"
  get "/user_pages/upload/form", to: "user_pages#upload_form", as: :user_pages_upload_form
  post "/user_pages/upload", to: "user_pages#upload", as: :user_pages_upload
  get "/user_pages/:id", to: "user_pages#show", as: :user_page
  get "/user_pages/:id/download", to: "user_pages#download", as: :user_pages_download
  delete "/user_pages/:id", to: "user_pages#destroy"
  # User-created pages
  resources :user_pages, only: [:index, :new, :create, :show] do
    member do
      get 'download'
      delete '', action: :destroy   # <-- add this line
    end

    collection do
      get 'upload/form', action: :upload_form
      post 'upload', action: :upload
    end
  end

  # Optional health check
  get "up" => "rails/health#show", as: :rails_health_check
end