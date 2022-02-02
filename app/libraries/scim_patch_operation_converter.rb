# frozen_string_literal: true

# 1. Convert each multi-value operation to single-value operations.
# 2. Fix wrong "value".
# 3. convert "op" to lower case
#
# About #1
# to handle request pattern A and B in the same way,
# convert complex-value to path + single-value
#
# Typical request is path_base = nil and value = complex-value:
# {
#   "op": "replace",
#   "value": {
#       "displayName": "Taro Suzuki",
#       "name.givenName": "taro"
#   }
# }
#
# This request is converted to:
# [
#   {
#     "op": "replace",
#     "path": "displayName",
#     "value": "Taro Suzuki",
#   }
#   {
#     "op": "replace",
#     "path": "name.givenName",
#     "value": "taro"
#   }
# ]
class ScimPatchOperationConverter
  class << self
    def convert(operations)
      operations.each_with_object([]) do |o, result|
        value = o['value']
        value = value.permit!.to_h if value.instance_of?(ActionController::Parameters)

        if value.is_a?(Hash)
          converted_operations = convert_to_single_value_operations(o['op'], o['path'],
                                                                    value)
          result.concat(converted_operations)
          next
        end

        result << fix_operation_format(o['op'], o['path'], value)
      end
    end

    private

      def convert_to_single_value_operations(op, path_base, hash_value)
        hash_value.map do |k, v|
          path = if path_base.present?
                   "#{path_base}.#{k}"
                 else
                   k
                 end
          fix_operation_format(op, path, v)
        end
      end

      def fix_operation_format(op, path, value)
        { 'op' => op.downcase, 'path' => path, 'value' => fix_value(value, path) }
      end

      def fix_value(value, path)
        if path == 'active'
          convert_bool_if_string(value)
        else
          value
        end
      end

      # According to SCIM, correct value in requests from Azure AD.
      # When using non-application gallery in Azure AD, and feature flag is not specified,
      # Azure AD sends string for 'active' attribute
      def convert_bool_if_string(value)
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
end
