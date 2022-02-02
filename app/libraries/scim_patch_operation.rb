# frozen_string_literal: true

# Parse One of "Operations" in PATCH request
class ScimPatchOperation
  attr_reader :op, :path_scim, :path_sp, :value

  # path presence is guaranteed by ScimPatchOperationConverter
  #
  # value must be String or Array.
  # complex-value(Hash) is converted to multiple single-value operations by ScimPatchOperationConverter
  def initialize(op, path, value, mutable_attributes_schema_test: nil)
    if !op.in?(%w[add replace remove]) || path.nil?
      raise ScimRails::ExceptionHandler::UnsupportedPatchRequest
    end

    # for test
    @mutable_attributes_schema = mutable_attributes_schema_test

    # define validate method in the inherited class
    validate(op, path, value)

    @op = op
    @path_scim = path
    @value = value

    # define convert_path method in the inherited class
    @path_sp = convert_path(path)
  end

  private

    def mutable_attributes_schema
      return @mutable_attributes_schema if @mutable_attributes_schema.present?

      # define schema method in the inherited class
      operation_mutable_attributes_schema
    end
end
