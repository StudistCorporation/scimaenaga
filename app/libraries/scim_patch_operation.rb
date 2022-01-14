# frozen_string_literal: true

# Parse One of "Operations" in PATCH request
class ScimPatchOperation
  attr_accessor :op, :path_scim, :path_sp, :value

  def initialize(op, path, value, mutable_attributes_schema)
    # FIXME: Raise proper Error
    raise StandardError unless op.downcase.in? %w[add replace remove]

    # No path is not supported.
    # FIXME: Raise proper Error
    raise ScimRails::ExceptionHandler::UnsupportedPatchRequest if path.nil?
    raise ScimRails::ExceptionHandler::UnsupportedPatchRequest if value.nil?

    @op = op.downcase.to_sym
    @path_scim = path
    @path_sp = convert_path(path, mutable_attributes_schema)
    @value = convert_bool_if_string(value)
  end

  def save(model)
    if @path_scim == 'members' # Only members are supported for value is an array
      update_member_ids = @value.map do |v|
        v[ScimRails.config.group_member_relation_schema.keys.first]
      end

      current_member_ids = model
                           .public_send(ScimRails.config.group_member_relation_attribute)
      case @op
      when :add
        member_ids = current_member_ids.concat(update_member_ids)
      when :replace
        member_ids = current_member_ids.concat(update_member_ids)
      when :remove
        member_ids = current_member_ids - update_member_ids
      end

      # Only the member addition process is saved by each ids
      model.public_send("#{ScimRails.config.group_member_relation_attribute}=",
                        member_ids.uniq)
      return
    end
    return if @path_sp.nil?
    case @op
    when :add, :replace
      model.attributes = { @path_sp => @value }
    when :remove
      model.attributes = { @path_sp => nil }
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
      dig_keys = path.gsub(/\[(.+?)\]/, '.0').split('.').map do |step|
        step == '0' ? 0 : step.to_sym
      end
      mutable_attributes_schema.dig(*dig_keys)
    end

    def convert_bool_if_string(value)
      case value
      when 'true', 'True' then
        return true
      when 'false', 'False' then
        return false
      else
        return value
      end
    end
end
