# frozen_string_literal: true

# Parse One of "Operations" in PATCH request
class ScimPatchOperation
  attr_accessor :op, :path_scim, :path_sp, :value

  def initialize(op, path, value, mutable_attributes_schema)
    # FIXME: Raise proper Error
    raise StandardError unless op.in? %w[Add Replace Remove]

    # No path is not supported.
    # FIXME: Raise proper Error
    raise StandardError if path.nil?

    @op = op.downcase.to_sym
    @path_scim = path
    @path_sp = convert_path(path, mutable_attributes_schema)
    @value = value
  end

  # WIP
  def apply(model)
    case @op
    when :add
      model.assign_attributes(@path_sp, @value)
    when :replace
      model.assign_attributes(@path_sp, @value)
    when :remove
      model.assign_attributes(@path_sp, nil)
    end
  end

  private

  def convert_path(path, mutable_attributes_schema)
    # For now, library does not support Multi-Valued Attributes properly.
    # examle:
    #   path = 'emails[type eq "work"].value'
    #   mutable_attributes_schema = {
    #     emails: [
    #       {
    #         value: :mail_address,
    #      }
    #     ],
    #   }
    #
    #   Library ignores filter conditions (like [type eq "work"])
    #   and always uses the first element of the array
    dig_keys = path.gsub(/\[(.+?)\]/, ".0").split(".").map { |step| step == "0" ? 0 : step.to_sym }
    mutable_attributes_schema.dig(*dig_keys)
  end
end
