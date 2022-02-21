# frozen_string_literal: true

require 'spec_helper'

describe ScimPatchOperationUser do
  let(:op) { 'replace' }
  let(:path) { 'userName' }
  let(:value) { 'taro.suzuki' }
  let(:mutable_attributes_schema) do
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

  let(:operation) do
    described_class.new(
      op,
      path,
      value
    )
  end
  describe '#initialize' do
    context 'replace single attribute' do
      it {
        allow(Scimaenaga.config).to(
          receive(:mutable_user_attributes_schema).and_return(mutable_attributes_schema)
        )
        expect(operation.op).to eq 'replace'
        expect(operation.path_scim).to eq(attribute: path, rest_path: [])
        expect(operation.path_sp).to eq :name
        expect(operation.value).to eq value
      }
    end

    context 'add single attribute' do
      let(:op) { 'add' }
      it {
        allow(Scimaenaga.config).to(
          receive(:mutable_user_attributes_schema).and_return(mutable_attributes_schema)
        )
        expect(operation.op).to eq 'add'
        expect(operation.path_scim).to eq(attribute: path, rest_path: [])
        expect(operation.path_sp).to eq :name
        expect(operation.value).to eq value
      }
    end

    context 'remove single attribute' do
      let(:op) { 'remove' }
      it {
        allow(Scimaenaga.config).to(
          receive(:mutable_user_attributes_schema).and_return(mutable_attributes_schema)
        )
        expect(operation.op).to eq 'remove'
        expect(operation.path_scim).to eq(attribute: path, rest_path: [])
        expect(operation.path_sp).to eq :name
        expect(operation.value).to eq value
      }
    end

    context 'replace email address' do
      let(:path) { 'emails[type eq "work"].value' }
      let(:value) { 'taro.suzuki@example.com' }
      it {
        allow(Scimaenaga.config).to(
          receive(:mutable_user_attributes_schema).and_return(mutable_attributes_schema)
        )
        expect(operation.op).to eq 'replace'
        expect(operation.path_scim).to eq(attribute: 'emails',
                                          filter: { attribute: 'type', operator: 'eq', parameter: 'work' }, rest_path: ['value'])
        expect(operation.path_sp).to eq :email
        expect(operation.value).to eq value
      }
    end

    context 'replace name.familyName' do
      let(:path) { 'name.familyName' }
      let(:value) { 'Suzuki' }
      it {
        allow(Scimaenaga.config).to(
          receive(:mutable_user_attributes_schema).and_return(mutable_attributes_schema)
        )
        expect(operation.op).to eq 'replace'
        expect(operation.path_scim).to eq(attribute: 'name', rest_path: ['familyName'])
        expect(operation.path_sp).to eq :family_name
        expect(operation.value).to eq value
      }
    end
  end
end
