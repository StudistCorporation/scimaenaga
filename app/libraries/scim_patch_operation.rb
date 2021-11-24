# frozen_string_literal: true

class ScimPatchOperation
  attr_accessor :op, :path_scim, :path_sp, :value

  def initialize(op, path, value, mutable_attributes_schema)      
    # FIXME: Raise proper Error
    raise StandardError unless op.in? ['Add', 'Replace', 'Remove']

    # No path is not supported.
    # FIXME: Raise proper Error
    raise StandardError if path.nil?

    @op = op.downcase.to_sym
    @path_scim = path

    # For now, library does not support model which has many email addresses.
    @path_sp = if path.start_with?('emails[')
      mutable_attributes_schema.dig(:emails, 0, :value)
    elsif path.include?('.')
      mutable_attributes_schema.dig(*path.split(/\./).map(&:to_sym))
    else
      mutable_attributes_schema[path.to_sym]
    end
    
    @value = value
  end

  # WIP
  def apply(model)
    case @op
    when :add
      model.update(@path_sp, @value)
    when :replace
      model.update(@path_sp, @value)
    when :remove
      model.update(@path_sp, nil)
    end
  end
end
