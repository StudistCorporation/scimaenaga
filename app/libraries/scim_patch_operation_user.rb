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

    def mutable_attributes_schema
      ScimRails.config.mutable_user_attributes_schema
    end

    def validate(_op, _path, value)
      if value.instance_of? Array
        raise ScimRails::ExceptionHandler::UnsupportedPatchRequest
      end

      return
    end

    def convert_path(path)
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

end
