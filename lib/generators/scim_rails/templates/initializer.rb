# frozen_string_literal: true

ScimRails.configure do |config|
  # Model used for authenticating and scoping users.
  config.basic_auth_model = "Company"

  # Attribute used to search for a given record. This
  # attribute should be unique as it will return the
  # first found record.
  config.basic_auth_model_searchable_attribute = :subdomain

  # Attribute used to compare Basic Auth password value.
  # Attribute will need to return plaintext for comparison.
  config.basic_auth_model_authenticatable_attribute = :api_token

  # Model used for user records.
  config.scim_users_model = "User"

  # Method used for retrieving user records from the
  # authenticatable model.
  config.scim_users_scope = :users

  # Determine whether the create endpoint updates users that already exist
  # or throws an error (returning 409 Conflict in accordance with SCIM spec)
  config.scim_user_prevent_update_on_create = false

  # Model used for group records.
  config.scim_groups_model = "Group"
  # Method used for retrieving user records from the
  # authenticatable model.
  config.scim_groups_scope = :groups

  # Cryptographic algorithm used for signing the auth tokens.
  # It supports all algorithms supported by the jwt gem.
  # See https://github.com/jwt/ruby-jwt#algorithms-and-usage for supported algorithms
  # It is "none" by default, hence generated tokens are unsigned
  # The tokens do not need to be signed if you only need basic authentication.
  # config.signing_algorithm = "HS256"

  # Secret token used to sign authorization tokens
  # It is `nil` by default, hence generated tokens are unsigned
  # The tokens do not need to be signed if you only need basic authentication.
  # config.signing_secret = SECRET_TOKEN

  # Default sort order for pagination is by id. If you
  # use non sequential ids for user records, uncomment
  # the below line and configure a determinate order.
  # For example, [:created_at, :id] or { created_at: :desc }.
  # config.scim_users_list_order = :id

  # Hash of queryable attribtues on the user model. If
  # the attribute is not listed in this hash it cannot
  # be queried by this Gem. The structure of this hash
  # is { queryable_scim_attribute => user_attribute }.
  config.queryable_user_attributes = {
    userName: :email,
    givenName: :first_name,
    familyName: :last_name,
    email: :email
  }

  # Array of attributes that can be modified on the
  # user model. If the attribute is not in this array
  # the attribute cannot be modified by this Gem.
  config.mutable_user_attributes = [
    :first_name,
    :last_name,
    :email
  ]

  # Hash of mutable attributes. This object is the map
  # for this Gem to figure out where to look in a SCIM
  # response for mutable values. This object should
  # include all attributes listed in
  # config.mutable_user_attributes.
  config.mutable_user_attributes_schema = {
    name: {
      givenName: :first_name,
      familyName: :last_name
    },
    emails: [
      {
        value: :email
      }
    ]
  }

  # Hash of SCIM structure for a user schema. This object
  # is what will be returned for a given user. The keys
  # in this object should conform to standard SCIM
  # structures. The values in the object will be
  # transformed per user record. Strings will be passed
  # through as is, symbols will be passed to the user
  # object to return a value.
  config.user_schema = {
    schemas: ["urn:ietf:params:scim:schemas:core:2.0:User"],
    id: :id,
    userName: :email,
    name: {
      givenName: :first_name,
      familyName: :last_name
    },
    emails: [
      {
        value: :email
      }
    ],
    active: :active?
  }

  # Schema for users used in "abbreviated" lists such as in
  # the `members` field of a Group.
  config.user_abbreviated_schema = {
    value: :id,
    display: :email
  }

  # Allow filtering Groups based on these parameters
  config.queryable_group_attributes = {
    displayName: :name
  }

  # List of attributes on a Group that can be updated through SCIM
  config.mutable_group_attributes = [
    :name
  ]

  # Hash of mutable Group attributes. This object is the map
  # for this Gem to figure out where to look in a SCIM
  # response for mutable values. This object should
  # include all attributes listed in
  # config.mutable_group_attributes.
  config.mutable_group_attributes_schema = {
    displayName: :name
  }

  # The User relation's IDs field name on the Group model.
  # Eg. if the relation is `has_many :users` this will be :user_ids
  config.group_member_relation_attribute = :user_ids
  # Which fields from the request's `members` field should be
  # assigned to the relation IDs field. Should include the field
  # set in config.group_member_relation_attribute.
  config.group_member_relation_schema = { value: :user_ids }

  config.group_schema = {
    schemas: ["urn:ietf:params:scim:schemas:core:2.0:Group"],
    id: :id,
    displayName: :name,
    members: :users
  }

  config.group_abbreviated_schema = {
    value: :id,
    display: :name
  }

  # Set group_destroy_method to a method on the Group model
  # to be called on a destroy request
  # config.group_destroy_method = :destroy!
end
