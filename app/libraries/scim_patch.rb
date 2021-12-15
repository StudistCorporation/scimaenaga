# frozen_string_literal: true

# Parse PATCH request
class ScimPatch
  attr_accessor :operations

  def initialize(params, mutable_attributes_schema)
    # FIXME: raise proper error.
    unless params["schemas"] == ["urn:ietf:params:scim:api:messages:2.0:PatchOp"]
      raise StandardError
    end
    if params["Operations"].nil?
      raise ScimRails::ExceptionHandler::UnsupportedPatchRequest
    end

    @operations = params["Operations"].map do |operation|
      ScimPatchOperation.new(operation["op"], operation["path"], operation["value"],
                             mutable_attributes_schema)
    end
  end

  def save(model)
    model.transaction do
      @operations.each do |operation|
        operation.save(model)
      end
    end
  model.save if model.changed?
  rescue ActiveRecord::RecordNotFound => e
    raise ActiveRecord::RecordNotFound
  rescue => e
    raise ScimRails::ExceptionHandler::UnsupportedPatchRequest
  end
end
