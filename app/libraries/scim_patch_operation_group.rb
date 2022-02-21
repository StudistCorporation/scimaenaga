# frozen_string_literal: true

class ScimPatchOperationGroup < ScimPatchOperation

  def save(model)
    if @path_scim[:attribute] == 'members'
      save_members(model)
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

    def save_members(model)
      current_member_ids = model.public_send(member_relation_attribute).map(&:to_s)

      case @op
      when 'add'
        member_ids = add_member_ids(current_member_ids)
      when 'replace'
        member_ids = replace_member_ids
      when 'remove'
        member_ids = remove_member_ids(current_member_ids)
      end

      model.public_send("#{member_relation_attribute}=", member_ids.uniq)
    end

    def add_member_ids(current_member_ids)
      current_member_ids.concat(member_ids_from_value)
    end

    def replace_member_ids
      member_ids_from_value
    end

    def remove_member_ids(current_member_ids)
      removed_member_ids = if member_ids_from_value.present?
                             member_ids_from_value
                           else
                             [member_id_from_filter]
                           end
      current_member_ids - removed_member_ids
    end

    def member_ids_from_value
      @member_ids_from_value ||= @value&.map do |v|
        v['value'].to_s
      end
    end

    def member_id_from_filter
      @path_scim.dig(:filter, :parameter)
    end

    def member_relation_attribute
      Scimaenaga.config.group_member_relation_attribute
    end

    def validate(_op, _path, _value)
      return
    end

    def path_scim_to_path_sp(path_scim)
      # path_scim example1:
      # {
      #   attribute: 'members',
      #   filter: {
      #     attribute: 'value',
      #     operator: 'eq',
      #     parameter: 'XXXX'
      #   },
      #   rest_path: []
      # }

      # path_scim example2:
      # {
      #   attribute: 'displayName',
      #   filter: nil,
      #   rest_path: []
      # }
      if path_scim[:attribute] == 'members'
        return Scimaenaga.config.group_member_relation_attribute
      end

      dig_keys = [path_scim[:attribute].to_sym]
      dig_keys.concat(path_scim[:rest_path].map(&:to_sym))

      # *dig_keys example: displayName
      Scimaenaga.config.mutable_group_attributes_schema.dig(*dig_keys)
    end

end
