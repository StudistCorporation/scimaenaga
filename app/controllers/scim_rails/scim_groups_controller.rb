# frozen_string_literal: true

module Scimaenaga
  class ScimGroupsController < Scimaenaga::ApplicationController
    def index
      if params[:filter].present?
        query = Scimaenaga::ScimQueryParser.new(
          params[:filter], Scimaenaga.config.queryable_group_attributes
        )

        groups = @company
                 .public_send(Scimaenaga.config.scim_groups_scope)
                 .where(
                   "#{Scimaenaga.config.scim_groups_model
                               .connection.quote_column_name(query.attribute)}
                               #{query.operator} ?",
                   query.parameter
                 )
                 .order(Scimaenaga.config.scim_groups_list_order)
      else
        groups = @company
                 .public_send(Scimaenaga.config.scim_groups_scope)
                 .preload(:users)
                 .order(Scimaenaga.config.scim_groups_list_order)
      end

      counts = ScimCount.new(
        start_index: params[:startIndex],
        limit: params[:count],
        total: groups.count
      )

      json_scim_response(object: groups, counts: counts)
    end

    def show
      group = @company
              .public_send(Scimaenaga.config.scim_groups_scope)
              .find(params[:id])
      json_scim_response(object: group)
    end

    def create
      group = @company
              .public_send(Scimaenaga.config.scim_groups_scope)
              .create!(permitted_group_params)

      json_scim_response(object: group, status: :created)
    end

    def put_update
      group = @company
              .public_send(Scimaenaga.config.scim_groups_scope)
              .find(params[:id])
      group.update!(permitted_group_params)
      json_scim_response(object: group)
    end

    def patch_update
      group = @company
              .public_send(Scimaenaga.config.scim_groups_scope)
              .find(params[:id])
      patch = ScimPatch.new(params, :group)
      patch.save(group)

      json_scim_response(object: group)
    end

    def destroy
      unless Scimaenaga.config.group_destroy_method
        raise Scimaenaga::ExceptionHandler::InvalidConfiguration
      end

      group = @company
              .public_send(Scimaenaga.config.scim_groups_scope)
              .find(params[:id])
      raise ActiveRecord::RecordNotFound unless group

      begin
        group.public_send(Scimaenaga.config.group_destroy_method)
      rescue NoMethodError => e
        raise Scimaenaga::ExceptionHandler::InvalidConfiguration, e.message
      rescue ActiveRecord::RecordNotDestroyed => e
        raise Scimaenaga::ExceptionHandler::InvalidRequest, e.message
      rescue StandardError => e
        raise Scimaenaga::ExceptionHandler::UnexpectedError, e.message
      end

      head :no_content
    end

    private

      def permitted_group_params
        converted = mutable_attributes.each.with_object({}) do |attribute, hash|
          hash[attribute] = find_value_for(attribute)
        end
        return converted unless params[:members]

        converted.merge(member_params)
      end

      def member_params
        {
          Scimaenaga.config.group_member_relation_attribute =>
            params[:members].map do |member|
              member[Scimaenaga.config.group_member_relation_schema.keys.first]
            end,
        }
      end

      def mutable_attributes
        Scimaenaga.config.mutable_group_attributes
      end

      def controller_schema
        Scimaenaga.config.mutable_group_attributes_schema
      end
  end
end
