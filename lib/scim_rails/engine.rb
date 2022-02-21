module Scimaenaga
  class Engine < ::Rails::Engine
    isolate_namespace Scimaenaga

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
