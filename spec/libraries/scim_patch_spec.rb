# frozen_string_literal: true

require 'spec_helper'

describe ScimPatch do
  shared_examples :user do
    let(:patch) { ScimPatch.new(params, :user) }
    it {
      allow(Scimaenaga.config).to(
        receive(:mutable_user_attributes_schema).and_return(mutable_user_attributes_schema)
      )

      expect(patch.operations[0].op).to eq 'replace'
      expect(patch.operations[0].path_scim).to eq(attribute: 'emails',
                                                  filter: { attribute: 'type', operator: 'eq', parameter: 'work' }, rest_path: ['value'])
      expect(patch.operations[0].path_sp).to eq :email
      expect(patch.operations[0].value).to eq 'taro.suzuki@example.com'

      expect(patch.operations[1].op).to eq 'replace'
      expect(patch.operations[1].path_scim).to eq(attribute: 'userName', rest_path: [])
      expect(patch.operations[1].path_sp).to eq :name
      expect(patch.operations[1].value).to eq 'taro.suzuki'

      expect(patch.operations[2].op).to eq 'replace'
      expect(patch.operations[2].path_scim).to eq(attribute: 'name',
                                                  rest_path: ['familyName'])
      expect(patch.operations[2].path_sp).to eq :family_name
      expect(patch.operations[2].value).to eq 'Suzuki'

      expect(patch.operations[3].op).to eq 'replace'
      expect(patch.operations[3].path_scim).to eq(attribute: 'active',
                                                  rest_path: [])
      expect(patch.operations[3].path_sp).to eq :active
      expect(patch.operations[3].value).to eq false
    }
  end

  let(:mutable_user_attributes_schema) do
    {
      userName: :name,
      displayName: :display_name,
      emails: [
        {
          value: :email,
        }
      ],
      name: {
        familyName: :family_name,
        givenName: :given_name,
      },
      active: :active,
    }
  end

  let(:mutable_group_attributes_schema) do
    {
      displayName: :name,
    }
  end

  describe '#initialize :user' do
    context :multiple_single_value_operations do
      let(:params) do
        {
          'schemas' => ['urn:ietf:params:scim:api:messages:2.0:PatchOp'],
          'Operations' => [
            {
              'op' => 'Replace',
              'path' => 'emails[type eq "work"].value',
              'value' => 'taro.suzuki@example.com',
            },
            {
              'op' => 'Replace',
              'path' => 'userName',
              'value' => 'taro.suzuki',
            },
            {
              'op' => 'Replace',
              'path' => 'name.familyName',
              'value' => 'Suzuki',
            },
            {
              'op' => 'Replace',
              'path' => 'active',
              'value' => 'False',
            }
          ],
        }
      end
      it_behaves_like :user
    end

    context :multiple_value_operation do
      let(:params) do
        {
          'schemas' => ['urn:ietf:params:scim:api:messages:2.0:PatchOp'],
          'Operations' => [
            {
              'op' => 'replace',
              'path' => 'emails[type eq "work"].value',
              'value' => 'taro.suzuki@example.com',
            },
            {
              'op' => 'replace',
              'value' => {
                'userName' => 'taro.suzuki',
                'name.familyName' => 'Suzuki',
                'active' => false,
              },
            }
          ],
        }
      end
      it_behaves_like :user
    end
  end

  describe '#initialize :group' do
    let(:params) do
      {
        'schemas' => ['urn:ietf:params:scim:api:messages:2.0:PatchOp'],
        'Operations' => [
          {
            'op' => 'Replace',
            'path' => 'displayName',
            'value' => 'groupA',
          },
          {
            'op' => 'Add',
            'path' => 'members',
            'value' => [
              {
                'value' => '1',
              },
              {
                'value' => '2',
              }
            ],
          }
        ],
      }
    end
    let(:patch) { described_class.new(params, :group) }
    it {
      allow(Scimaenaga.config).to(
        receive(:mutable_group_attributes_schema).and_return(mutable_group_attributes_schema)
      )

      expect(patch.operations[0].op).to eq 'replace'
      expect(patch.operations[0].path_scim).to eq(attribute: 'displayName', rest_path: [])
      expect(patch.operations[0].path_sp).to eq :name
      expect(patch.operations[0].value).to eq 'groupA'

      expect(patch.operations[1].op).to eq 'add'
      expect(patch.operations[1].path_scim).to eq(attribute: 'members', rest_path: [])
      expect(patch.operations[1].path_sp).to eq :user_ids
      expect(patch.operations[1].value).to eq [{ 'value' => '1' }, { 'value' => '2' }]
    }
  end

  # describe '#update' do
  # create user by factory bot
  # patch.update(user)
  # end
end
