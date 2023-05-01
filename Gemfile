source 'https://rubygems.org'

# Declare your gem's dependencies in scimaenaga.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem 'rails', '>= 5.2.4.6', '< 7.1'

group :development, :test do
  gem 'pry'
  gem 'pry-nav'
  gem 'rubocop'

  # Since rails 7.0, rails does not require sprockets-rails.
  # This is added to run the same tests as in previous versions.
  gem 'sprockets-rails'
end
