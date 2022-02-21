class ScimaenagaGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def copy_initializer_file
    copy_file 'initializer.rb', 'config/initializers/scimaenaga_config.rb'
  end
end
