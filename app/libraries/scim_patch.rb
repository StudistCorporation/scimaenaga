# frozen_string_literal: true

# Parse PATCH request
class ScimPatch
  attr_accessor :operations

  def initialize(params, mutable_attributes_schema)
    # FIXME: raise proper error.
    raise StandardError unless params["schemas"] == ["urn:ietf:params:scim:api:messages:2.0:PatchOp"]

    @operations = params["Operations"].map do |operation|
      ScimPatchOperation.new(operation["op"], operation["path"], operation["value"], mutable_attributes_schema)
    end
  end

  # WIP
  def apply(model)
    @operations.each do |operation|
      operation.apply(model)
    end
    model
  end
end
