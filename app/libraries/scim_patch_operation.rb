# frozen_string_literal: true

# Parse One of "Operations" in PATCH request
class ScimPatchOperation

  # 1 Operation means 1 attribute change
  # If 1 value is specified, @operations has 1 "Operation" struct.
  # If 3 value is specified, @operations has 3 "Operation" struct.
  attr_accessor :operations

  Operation = Struct.new('Operation', :op, :path_scim, :path_sp, :value)

  def initialize(op, path, value, mutable_attributes_schema)
    op_downcase = op.downcase

    unless op_downcase.in? %w[add replace remove]
      raise ScimRails::ExceptionHandler::UnsupportedPatchRequest
    end

    @operations = []

    # To handle request pattern A and B in the same way,
    # convert complex-value to path + single-value
    #
    # pattern A
    # {
    #   "op": "replace",
    #   "value": {
    #       "displayName": "Suzuki Taro",
    #       "name.givenName": "taro"
    #   }
    # }
    # => [{path: displayName, value: "Suzuki Taro"}, {path: name.givenName, value: "taro"}]
    #
    # pattern B
    # [
    #   {
    #     "op": "replace",
    #     "path": "displayName"
    #     "value": "Suzuki Taro",
    #   },
    #   {
    #     "op": "replace",
    #     "path": "name.givenNAme"
    #     "value": "taro",
    #   },
    # ]
    if value.instance_of?(Hash) || value.instance_of?(ActionController::Parameters)
      create_multiple_operations(op_downcase, path, value, mutable_attributes_schema)
    else
      create_operation(op_downcase, path, value, mutable_attributes_schema)
    end
  end

  def save(model)
    @operations.each do |operation|
      apply_operation(model, operation)
    end
  end

  private

    def apply_operation(model, operation)
      if operation.path_scim == 'members' # Only members are supported for value is an array
        update_member_ids = operation.value.map do |v|
          v[ScimRails.config.group_member_relation_schema.keys.first]
        end

        current_member_ids = model.public_send(
          ScimRails.config.group_member_relation_attribute
        )
        case operation.op
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
      end

      case operation.op
      when :add, :replace
        model.attributes = { operation.path_sp => operation.value }
      when :remove
        model.attributes = { operation.path_sp => nil }
      end
    end

    def create_operation(op, path_scim, value, mutable_attributes_schema)
      path_sp = convert_path(path_scim, mutable_attributes_schema)
      value = convert_bool_if_string(value, path_scim)
      @operations << Operation.new(op.to_sym, path_scim, path_sp, value)
    end

    # convert hash value to 1 path + 1 value
    # each path is created by path_scim_base + key of value
    def create_multiple_operations(op, path_scim_base, hash_value, mutable_attributes_schema)
      hash_value.each do |k, v|
        # Typical request is path_scim_base = nil and value = complex-value:
        # {
        #   "op": "replace",
        #   "value": {
        #       "displayName": "Taro Suzuki",
        #       "name.givenName": "taro"
        #   }
        # }
        path_scim = if path_scim_base.present?
                      "#{path_scim_base}.#{k}"
                    else
                      k
                    end
        create_operation(op, path_scim, v, mutable_attributes_schema)
      end
    end

    def convert_path(path, mutable_attributes_schema)
      return nil if path.nil?

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

    def convert_bool_if_string(value, path)
      # This method correct value in requests from Azure AD according to SCIM.
      # When path is not active, do nothing and return
      return value if path != 'active'

      case value
      when 'true', 'True'
        return true
      when 'false', 'False'
        return false
      else
        return value
      end
    end
end
