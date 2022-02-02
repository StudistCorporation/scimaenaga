# frozen_string_literal: true

# Parse One of "Operations" in PATCH request
class ScimPatchOperation
  attr_reader :op, :path_scim, :path_sp, :value

  # path presence is guaranteed by ScimPatchOperationConverter
  #
  # value must be String or Array.
  # complex-value(Hash) is converted to multiple single-value operations by ScimPatchOperationConverter
  def initialize(op, path, value)
    if !op.in?(%w[add replace remove]) || path.nil?
      raise ScimRails::ExceptionHandler::UnsupportedPatchRequest
    end

    # define validate method in the inherited class
    validate(op, path, value)

    @op = op
    @value = value
    @path_scim = parse_path_scim(path)
    @path_sp = path_scim_to_path_sp(@path_scim)

    # define parse method in the inherited class
  end

  private

    def parse_path_scim(path)
      # 'emails[type eq "work"].value' is parsed as follows:
      #
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
      # This method suport only single operator

      # path: emails.value
      # filter_string: type eq "work"
      path_str = path.dup
      filter_string = path_str.slice!(/\[(.+?)\]/, 0)&.slice(/\[(.+?)\]/, 1)

      # path_elements: ['emails', 'value']
      path_elements = path_str.split('.')

      # filter_elements: ['type', 'eq', '"work"']
      filter_elements = filter_string&.split(' ')
      path_scim = {attribute: path_elements[0], rest_path: path_elements[1..nil]}
      if filter_elements.present?
        path_scim[:filter] = {
          attribute: filter_elements[0],
          operator: filter_elements[1],
          # delete double quotation
          parameter: filter_elements[2].slice(1...filter_elements[2].length - 1),
        }
      end

      path_scim
    end

end
