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

  # /Schemas settings.
  # This configure is not used in /Users and /Groups for now.
  # Configure this only when you need Schemas endpoint.
  # Schemas endpoint returns configured value as it is.
  config.schemas = [
    # Define User schemas
    {
      # Normally you don't have to change schemas/id/name/description
      schemas: ['urn:ietf:params:scim:schemas:core:2.0:Schema'],
      id: 'urn:ietf:params:scim:schemas:core:2.0:User',
      name: 'User',
      description: 'User Account',

      # Configure 'attributes' as it corresponds with other configurations and your model
      attributes: [
        {
          # Name of SCIM attribute. It must be configured in "user_schema"
          name: 'userName',

          # "type" must be string/boolan/decimal/integer/dateTime/reference
          # "complex" value is not supported now
          type: 'string',

          # Multi value attribute is not supported, must be false
          multiValued: false,

          description: 'Unique identifier for the User. REQUIRED.',

          # Specify true when you require this attribute
          required: true,

          # In this Library, String value is always handled as case exact
          caseExact: true,

          # "mutability" must be readOnly/readWrite/writeOnly
          # "immutable" is not supported.
          # readOnly: attribute is defined in queryable_user_attributes but not in mutable_user_attributes and user_schema
          # readWrite: attribute is defined in queryable_user_attributes, mutable_user_attributes and user_schema
          # writeOnly: attribute is defined in mutable_user_attributes, and user_schema but not in queryable_user_attributes
          mutability: 'readWrite',

          # "returned" must be always/never. default and request are not supported
          # always: attribute is defined in user_schema
          # never: attribute is not defined in user_schema
          returned: 'always',

          # "uniqueness" must be none/server/global. It's dependent on your service
          uniqueness: 'server',
        }
      ],
      meta: {
        resourceType: 'Schema',
        location:
          '/v2/Schemas/urn:ietf:params:scim:schemas:core:2.0:User',
      },
    },
    # define Group schemas
    {
      schemas: ['urn:ietf:params:scim:schemas:core:2.0:Schema'],
      id: 'urn:ietf:params:scim:schemas:core:2.0:Group',
      name: 'Group',
      description: 'Group',
      attributes: [
        {
          # Same as the User attributes
          name: 'displayName',
          type: 'string',
          multiValued: false,
          description: 'A human-readable name for the Group. REQUIRED.',
          required: true,
          caseExact: true,
          mutability: 'readWrite',
          returned: 'always',
          uniqueness: 'none',
        },
        {
          name: 'members',

          # Only "members" can be configured as a complex and multivalued attribute
          type: 'complex',
          multiValued: true,

          description: 'A list of members of the Group.',
          required: false,
          subAttributes: [
            {
              name: 'value',
              type: 'string',
              multiValued: false,
              description: 'Identifier of the member of this Group.',
              required: false,
              caseExact: true,
              mutability: 'immutable',
              returned: 'default',
              uniqueness: 'none',
            }
          ],
        }
      ],
      meta: {
        resourceType: 'Schema',
        location: '/v2/Schemas/urn:ietf:params:scim:schemas:core:2.0:Group',
      },
    }
  ]
end
