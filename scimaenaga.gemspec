$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'scimaenaga/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = 'scimaenaga'
  s.version = Scimaenaga::VERSION
  s.authors = ['Studist Corporation']
  s.homepage = 'https://github.com/StudistCorporation/scimaenaga'
  s.summary = 'SCIM Adapter for Rails.'
  s.description = 'SCIM Adapter for Rails.'
  s.license = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.required_ruby_version = '>= 2.5.9'
  s.add_dependency 'jwt', '>= 1.5'
  s.add_dependency 'rails', '>= 7.0', '< 8.1'
  s.test_files = Dir['spec/**/*']

  s.add_development_dependency 'bundler', '~> 2.0'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3'
  s.metadata = {
    'rubygems_mfa_required' => 'true',
  }
end
