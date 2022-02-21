module ScimRails
  class AuthorizeApiRequest

    def initialize(searchable_attribute:, authentication_attribute:)
      @searchable_attribute = searchable_attribute
      @authentication_attribute = authentication_attribute

      if searchable_attribute.blank? || authentication_attribute.blank?
        raise ScimRails::ExceptionHandler::InvalidCredentials
      end

      @search_parameter = { ScimRails.config.basic_auth_model_searchable_attribute => @searchable_attribute }
    end

    def company
      company = find_company
      authorize(company)
      company
    end

    private

      attr_reader :authentication_attribute, :search_parameter, :searchable_attribute

      def find_company
        @company ||= ScimRails.config.basic_auth_model.find_by!(search_parameter)
      rescue ActiveRecord::RecordNotFound
        raise ScimRails::ExceptionHandler::InvalidCredentials
      end

      def authorize(authentication_model)
        authorized = ActiveSupport::SecurityUtils.secure_compare(
          authentication_model.public_send(ScimRails.config.basic_auth_model_authenticatable_attribute),
          authentication_attribute
        )
        raise ScimRails::ExceptionHandler::InvalidCredentials unless authorized
      end
  end
end
