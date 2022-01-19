# frozen_string_literal: true

require 'spec_helper'

describe ScimPatch do

  let(:params) {
    {
      'schemas' => ['urn:ietf:params:scim:api:messages:2.0:PatchOp'],
      'Operations' => [
        {
          'op' => 'Replace',
          'path' => 'userName',
          'value' => 'taro.suzuki'
        },
        {
          'op' =>  'Replace',
          'path' => 'emails[type eq "work"].value',
          'value' => 'taro.suzuki@example.com'
        },
        {
          'op' => 'Replace',
          'path' => 'name.familyName',
          'value' => 'Suzuki'
        },
        {
          'op' => 'Replace',
          'path' => 'active',
          'value' => 'False'
        }
      ]
    }
  }

  let(:mutable_attributes_schema) {
    {
      userName: :name,
      displayName: :display_name,
      emails: [
        {
          value: :email
        }
      ],
      name: {
        familyName: :family_name,
        givenName: :given_name
      },
      active: :active
    }
  }

  let(:patch) { described_class.new(params, mutable_attributes_schema) }

  describe '#initialize' do
    it {
      expect(patch.operations[0].op).to eq :replace
      expect(patch.operations[0].path_scim).to eq 'userName'
      expect(patch.operations[0].path_sp).to eq :name
      expect(patch.operations[0].value).to eq 'taro.suzuki'

      expect(patch.operations[1].op).to eq :replace
      expect(patch.operations[1].path_scim).to eq 'emails[type eq "work"].value'
      expect(patch.operations[1].path_sp).to eq :email
      expect(patch.operations[1].value).to eq 'taro.suzuki@example.com'

      expect(patch.operations[2].op).to eq :replace
      expect(patch.operations[2].path_scim).to eq 'name.familyName'
      expect(patch.operations[2].path_sp).to eq :family_name
      expect(patch.operations[2].value).to eq 'Suzuki'

      expect(patch.operations[3].op).to eq :replace
      expect(patch.operations[3].path_scim).to eq 'active'
      expect(patch.operations[3].path_sp).to eq :active
      expect(patch.operations[3].value).to eq false
    }
  end

  # describe '#update' do
    # create user by factory bot
    # patch.update(user)
  # end

end
