# frozen_string_literal: true

class ScimPatchOperationGroup < ScimPatchOperation

  def save(model)
    if @path_scim == 'members' # Only members are supported for value is an array
      update_member_ids = @value.map do |v|
        v[ScimRails.config.group_member_relation_schema.keys.first].to_s
      end

      current_member_ids = model.public_send(
        ScimRails.config.group_member_relation_attribute
      ).map(&:to_s)
      case @op
      when 'add'
        member_ids = current_member_ids.concat(update_member_ids)
      when 'replace'
        member_ids = current_member_ids.concat(update_member_ids)
      when 'remove'
        member_ids = current_member_ids - update_member_ids
      end

      # Only the member addition process is saved by each ids
      model.public_send("#{ScimRails.config.group_member_relation_attribute}=",
                        member_ids.uniq)
      return
    end

    case @op
    when 'add', 'replace'
      model.attributes = { @path_sp => @value }
    when 'remove'
      model.attributes = { @path_sp => nil }
    end
  end

  private

    def mutable_attributes_schema
      ScimRails.config.mutable_group_attributes_schema
    end

    def validate(_op, _path, _value)
      return
    end

    def convert_path(_path)
      # TODO: When feature flag is specified,
      #       Azure AD sends member remove request as follows:
      # "Operations": [
      #   {
      #       "op": "remove",
      #       "path": "members[value eq \"7f4bc1a3-285e-48ae-8202-5accb43efb0e\"]"
      #   }
      # ]
      #
      # This format will have to be supported.
      mutable_attributes_schema.dig(*dig_keys)
    end

end
