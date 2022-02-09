# frozen_string_literal: true

module ScimRails
  class ScimSchemasController < ScimRails::ApplicationController
    def index
      schemas = ScimRails.config.schemas

      counts = ScimCount.new(
        start_index: params[:startIndex],
        limit: params[:count],
        total: schemas.count
      )

      list_schemas_response(schemas, counts)
    end

    def show
      schema = ScimRails.config.schemas.find do |s|
        s[:id] == params[:id]
      end

      raise ScimRails::ExceptionHandler::ResourceNotFound, params[:id] if schema.nil?

      json_response(schema)
    end

    private

      def list_schemas_response(schemas, counts)
        # start_index is 1-based index
        response = {
          schemas: [
            'urn:ietf:params:scim:api:messages:2.0:ListResponse'
          ],
          totalResults: counts.total,
          startIndex: counts.start_index,
          itemsPerPage: counts.limit,
          Resources: schemas[counts.offset...counts.offset + counts.limit],
        }
        json_response(response)
      end
  end
end
