source "https://rubygems.org"

# --- Core Rails Framework ---
gem "rails", "~> 8.0.3"
gem "puma", ">= 5.0"                   # Web server
gem "sqlite3", ">= 2.1"                # Local DB (swap for Postgres in production)
gem "propshaft"                        # Modern asset pipeline
gem "importmap-rails"                  # JavaScript import maps
gem "turbo-rails"                      # Hotwire Turbo
gem "stimulus-rails"                   # Hotwire Stimulus
gem "jbuilder"                         # JSON builder

# --- Performance & Caching ---
gem "bootsnap", require: false         # Faster boot times
gem "thruster", require: false         # HTTP asset caching & compression
gem "solid_cache"                      # Rails cache backend
gem "solid_queue"                      # Active Job backend
gem "solid_cable"                      # Action Cable backend

# --- Deployment & Infra ---
gem "kamal", require: false            # Docker/Kamal deployment

# --- OS Compatibility ---
gem "tzinfo-data", platforms: %i[windows jruby]

# --- Development & Testing ---
group :development, :test do
  # Debugging and linting
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false       # Security static analysis
  gem "rubocop-rails-omakase", require: false  # Style guide
end

group :development do
  # Developer tools
  gem "web-console"                    # In-browser console for errors

  # --- 🔥 LiveReload / Hot Reload Setup ---
  gem "listen", "~> 3.8"               # File watcher for reloading
  gem "guard"                          # File monitor
  gem "guard-livereload", require: false  # Auto browser refresh
  gem "rack-livereload"                # Inject reload script into pages
end

group :test do
  # System testing tools
  gem "capybara"
  gem "selenium-webdriver"
end

# Optional: gem "image_processing", "~> 1.2" for ActiveStorage variants
# Optional: gem "bcrypt", "~> 3.1.7" for password hashing
