# frozen_string_literal: true

class ScimPatch
  attr_accessor :operations

  def initialize(params, mutable_attributes_schema)
    # FIXME: raise proper error.
    unless params['schemas'] == ['urn:ietf:params:scim:api:messages:2.0:PatchOp']
      raise StandardError 
    end

    @operations = params["Operations"].map do |operation|
      ScimPatchOperation.new(operation["op"], operation["path"], operation["value"], mutable_attributes_schema)
    end
  end

  # WIP
  def apply(model)
    @operations.each do |operation|
      operation.update(model)
    end
    return model
  end
end
