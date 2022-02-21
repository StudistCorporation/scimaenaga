# frozen_string_literal: true

module Scimaenaga
  class ScimUsersController < Scimaenaga::ApplicationController

    def index
      if params[:filter].present?
        query = Scimaenaga::ScimQueryParser.new(
          params[:filter], Scimaenaga.config.queryable_user_attributes
        )

        users = @company
                .public_send(Scimaenaga.config.scim_users_scope)
                .where(
                  "#{Scimaenaga.config.scim_users_model
              .connection.quote_column_name(query.attribute)} #{query.operator} ?",
                  query.parameter
                )
                .order(Scimaenaga.config.scim_users_list_order)
      else
        users = @company
                .public_send(Scimaenaga.config.scim_users_scope)
                .order(Scimaenaga.config.scim_users_list_order)
      end

      counts = ScimCount.new(
        start_index: params[:startIndex],
        limit: params[:count],
        total: users.count
      )

      json_scim_response(object: users, counts: counts)
    end

    def create
      if Scimaenaga.config.scim_user_prevent_update_on_create
        user = @company
               .public_send(Scimaenaga.config.scim_users_scope)
               .create!(permitted_user_params)
      else
        username_key = Scimaenaga.config.queryable_user_attributes[:userName]
        find_by_username = {}
        find_by_username[username_key] = permitted_user_params[username_key]
        user = @company
               .public_send(Scimaenaga.config.scim_users_scope)
               .find_or_create_by(find_by_username)
        user.update!(permitted_user_params)
      end
      json_scim_response(object: user, status: :created)
    end

    def show
      user = @company.public_send(Scimaenaga.config.scim_users_scope).find(params[:id])
      json_scim_response(object: user)
    end

    def put_update
      user = @company.public_send(Scimaenaga.config.scim_users_scope).find(params[:id])
      user.update!(permitted_user_params)
      json_scim_response(object: user)
    end

    def patch_update
      user = @company.public_send(Scimaenaga.config.scim_users_scope).find(params[:id])
      patch = ScimPatch.new(params, :user)
      patch.save(user)

      json_scim_response(object: user)
    end

    def destroy
      unless Scimaenaga.config.user_destroy_method
        raise Scimaenaga::ExceptionHandler::InvalidConfiguration
      end

      user = @company.public_send(Scimaenaga.config.scim_users_scope).find(params[:id])
      raise ActiveRecord::RecordNotFound unless user

      begin
        user.public_send(Scimaenaga.config.user_destroy_method)
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

      def permitted_user_params
        Scimaenaga.config.mutable_user_attributes.each.with_object({}) do |attribute, hash|
          hash[attribute] = find_value_for(attribute)
        end
      end

      def controller_schema
        Scimaenaga.config.mutable_user_attributes_schema
      end
  end
end
