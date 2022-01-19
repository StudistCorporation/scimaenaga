# frozen_string_literal: true

module ScimRails
  class ScimUsersController < ScimRails::ApplicationController


    def index
      if params[:filter].present?
        query = ScimRails::ScimQueryParser.new(
          params[:filter], ScimRails.config.queryable_user_attributes
        )

        users = @company
                .public_send(ScimRails.config.scim_users_scope)
                .where(
                  "#{ScimRails.config.scim_users_model
              .connection.quote_column_name(query.attribute)} #{query.operator} ?",
                  query.parameter
                )
                .order(ScimRails.config.scim_users_list_order)
      else
        users = @company
                .public_send(ScimRails.config.scim_users_scope)
                .order(ScimRails.config.scim_users_list_order)
      end

      counts = ScimCount.new(
        start_index: params[:startIndex],
        limit: params[:count],
        total: users.count
      )

      json_scim_response(object: users, counts: counts)
    end

    def create
      if ScimRails.config.scim_user_prevent_update_on_create
        user = @company
               .public_send(ScimRails.config.scim_users_scope)
               .create!(permitted_user_params)
      else
        username_key = ScimRails.config.queryable_user_attributes[:userName]
        find_by_username = {}
        find_by_username[username_key] = permitted_user_params[username_key]
        user = @company
               .public_send(ScimRails.config.scim_users_scope)
               .find_or_create_by(find_by_username)
        user.update!(permitted_user_params)
      end
      json_scim_response(object: user, status: :created)
    end



    def show
      user = @company.public_send(ScimRails.config.scim_users_scope).find(params[:id])
      json_scim_response(object: user)
    end

    def put_update
      user = @company.public_send(ScimRails.config.scim_users_scope).find(params[:id])
      user.update!(permitted_user_params)
      json_scim_response(object: user)
    end

    def patch_update
      user = @company.public_send(ScimRails.config.scim_users_scope).find(params[:id])
      patch = ScimPatch.new(params, ScimRails.config.mutable_user_attributes_schema)
      patch.save(user)

      json_scim_response(object: user)
    end

    def destroy
      unless ScimRails.config.user_destroy_method
        raise ScimRails::ExceptionHandler::UnsupportedDeleteRequest
      end

      user = @company.public_send(ScimRails.config.scim_users_scope).find(params[:id])
      user.public_send(ScimRails.config.user_destroy_method)
      head :no_content
    end

    private

      def permitted_user_params
        ScimRails.config.mutable_user_attributes.each.with_object({}) do |attribute, hash|
          hash[attribute] = find_value_for(attribute)
        end
      end

      def controller_schema
        ScimRails.config.mutable_user_attributes_schema
      end
  end
end
