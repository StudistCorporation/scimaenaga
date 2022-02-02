# frozen_string_literal: true

class ScimPatchOperationUser < ScimPatchOperation

  def save(model)
    case @op
    when 'add', 'replace'
      model.attributes = { @path_sp => @value }
    when 'remove'
      model.attributes = { @path_sp => nil }
    end
  end

  private

    def validate(_op, _path, value)
      if value.instance_of? Array
        raise ScimRails::ExceptionHandler::UnsupportedPatchRequest
      end

      return
    end

    def path_scim_to_path_sp(path_scim)
      # path_scim example1:
      # {
      #   attribute: 'emails',
      #   filter: {
      #     attribute: 'type',
      #     operator: 'eq',
      #     parameter: 'work'
      #   },
      #   rest_path: ['value']
      # }
      #
      # path_scim example2:
      # {
      #   attribute: 'name',
      #   filter: nil,
      #   rest_path: ['givenName']
      # }
      dig_keys = [path_scim[:attribute].to_sym]

      # Library ignores filter conditions ([type eq "work"])
      dig_keys << 0 if path_scim[:attribute] == 'emails'

      dig_keys.concat(path_scim[:rest_path].map(&:to_sym))

      # *dig_keys example: emails, 0, value
      ScimRails.config.mutable_user_attributes_schema.dig(*dig_keys)
    end

end
