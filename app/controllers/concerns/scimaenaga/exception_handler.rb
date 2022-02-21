# frozen_string_literal: true

module Scimaenaga
  module ExceptionHandler
    extend ActiveSupport::Concern

    class InvalidCredentials < StandardError
    end

    class InvalidRequest < StandardError
    end

    class InvalidQuery < StandardError
    end

    class UnsupportedPatchRequest < StandardError
    end

    class UnsupportedDeleteRequest < StandardError
    end

    class InvalidConfiguration < StandardError
    end

    class UnexpectedError < StandardError
    end

    class ResourceNotFound < StandardError
      attr_reader :id

      def initialize(id)
        super
        @id = id
      end
    end

    included do
      if Rails.env.production?
        rescue_from StandardError do |exception|
          on_error = Scimaenaga.config.on_error
          if on_error.respond_to?(:call)
            on_error.call(exception)
          else
            Rails.logger.error(exception.inspect)
          end

          json_response(
            {
              schemas: ['urn:ietf:params:scim:api:messages:2.0:Error'],
              status: '500',
            },
            :internal_server_error
          )
        end
      end

      rescue_from Scimaenaga::ExceptionHandler::InvalidCredentials do
        json_response(
          {
            schemas: ['urn:ietf:params:scim:api:messages:2.0:Error'],
            detail: 'Authorization failure. The authorization header is invalid or missing.',
            status: '401',
          },
          :unauthorized
        )
      end

      rescue_from Scimaenaga::ExceptionHandler::InvalidRequest do |e|
        json_response(
          {
            schemas: ['urn:ietf:params:scim:api:messages:2.0:Error'],
            detail: "Invalid request. #{e.message}",
            status: '400',
          },
          :bad_request
        )
      end

      rescue_from Scimaenaga::ExceptionHandler::InvalidQuery do
        json_response(
          {
            schemas: ['urn:ietf:params:scim:api:messages:2.0:Error'],
            scimType: 'invalidFilter',
            detail: 'The specified filter syntax was invalid, or the specified attribute and filter comparison combination is not supported.',
            status: '400',
          },
          :bad_request
        )
      end

      rescue_from Scimaenaga::ExceptionHandler::UnsupportedPatchRequest do
        json_response(
          {
            schemas: ['urn:ietf:params:scim:api:messages:2.0:Error'],
            detail: 'Invalid PATCH request.',
            status: '422',
          },
          :unprocessable_entity
        )
      end

      rescue_from Scimaenaga::ExceptionHandler::UnsupportedDeleteRequest do
        json_response(
          {
            schemas: ['urn:ietf:params:scim:api:messages:2.0:Error'],
            detail: 'Delete operation is disabled for the requested resource.',
            status: '501',
          },
          :not_implemented
        )
      end

      rescue_from Scimaenaga::ExceptionHandler::InvalidConfiguration do |e|
        json_response(
          {
            schemas: ['urn:ietf:params:scim:api:messages:2.0:Error'],
            detail: "Invalid configuration. #{e.message}",
            status: '500',
          },
          :internal_server_error
        )
      end

      rescue_from Scimaenaga::ExceptionHandler::UnexpectedError do |e|
        json_response(
          {
            schemas: ['urn:ietf:params:scim:api:messages:2.0:Error'],
            detail: "Unexpected Error. #{e.message}",
            status: '500',
          },
          :internal_server_error
        )
      end

      rescue_from ActiveRecord::RecordNotFound,
                  Scimaenaga::ExceptionHandler::ResourceNotFound do |e|
        json_response(
          {
            schemas: ['urn:ietf:params:scim:api:messages:2.0:Error'],
            detail: "Resource #{e.id} not found.",
            status: '404',
          },
          :not_found
        )
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        case e.message
        when /has already been taken/
          json_response(
            {
              schemas: ['urn:ietf:params:scim:api:messages:2.0:Error'],
              detail: e.message,
              status: '409',
            },
            :conflict
          )
        else
          json_response(
            {
              schemas: ['urn:ietf:params:scim:api:messages:2.0:Error'],
              detail: e.message,
              status: '422',
            },
            :unprocessable_entity
          )
        end
      end
    end
  end
end
