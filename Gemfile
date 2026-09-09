source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3", ">= 8.1.3.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# The typographic style this app is set in: the shell, the masthead, the
# footer, the value scale [https://github.com/bobbymeyer/its-swiss]
gem "its-swiss", "~> 1.0"
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# The tools. Each is a Rails engine packaged as a gem, taken from the
# default branch of its repository rather than from RubyGems;
# lib/chassis/engines.rb says where each is mounted. The branch is named
# rather than left off: with no ref at all, Bundler resolves whatever the
# cached clone's HEAD happens to be. No tag, because Gemfile.lock is
# committed and records the revision each tool is on, which is what makes a
# deploy reproducible. Nobody moves it by hand: each tool asks the chassis to
# take it when it merges, and .github/workflows/tools.yml takes the tools as
# they are, runs the suite against them and pushes the lock.
gem "pandatone", github: "bobbymeyer/pandatone", branch: "main"
gem "stripeclub", github: "bobbymeyer/stripeclub", branch: "main"
# Badger is two gems from one repository: the core (geometry and type
# setting, plain Ruby) and the engine, which depends on the core at exactly
# its own version. One git block takes both. Its type sidecar needs the
# Python packages in requirements.txt; the Dockerfile installs them.
git "https://github.com/bobbymeyer/badger", branch: "main" do
  gem "badger"
  gem "badger-rails"
end
# Projects: named projects that gather what the other tools have tagged.
# A path gem rather than a repository of its own — it is a whole mountable
# engine, with its own namespace, tables, dummy host and suite, and
# extracting it is moving the directory and changing this line. It lives here
# because it has one host and nothing else consumes it yet.
#
# It could not live in the chassis proper: it needs a table, a model and
# views, and test/architecture/thin_chassis_test.rb refuses all three. That
# is the guard working, not a rule to loosen.
gem "projects", path: "engines/projects"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# json 3.0.0 (7 September 2026) changed the signature of JSON.parse, and
# Active Support 8.1.3.1 still calls it the old way: a signed cookie, a JSON
# column and a schema load all raise. Every engine in this family already
# holds it below 3 in its own Gemfile; the chassis only avoided it by not
# having re-resolved since. Below 3 until a Rails that takes it.
gem "json", "< 3"


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
