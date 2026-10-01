Mime::Type.register "application/scim+json", :scimjson

original_parsers = ActionDispatch::Request.parameter_parsers
parsers = original_parsers.merge(scimjson: ->(body) { ActiveSupport::JSON.decode(body) })
ActionDispatch::Request.parameter_parsers = parsers
