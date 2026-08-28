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
      verify_member_ids!(patch.operations.flat_map(&:member_ids_to_assign))
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
        member_ids = params[:members].map do |member|
          member[Scimaenaga.config.group_member_relation_schema.keys.first]
        end
        verify_member_ids!(member_ids)
        { Scimaenaga.config.group_member_relation_attribute => member_ids }
      end

      # Without this a client could attach users of another company to its own group.
      def verify_member_ids!(member_ids)
        ids = member_ids.map(&:to_s).uniq
        users = @company.public_send(Scimaenaga.config.scim_users_scope)
        missing_ids = ids - users.where(users.primary_key => ids).ids.map(&:to_s)
        raise ExceptionHandler::ResourceNotFound, missing_ids if missing_ids.any?
      end

      def mutable_attributes
        Scimaenaga.config.mutable_group_attributes
      end

      def controller_schema
        Scimaenaga.config.mutable_group_attributes_schema
      end
  end
end
