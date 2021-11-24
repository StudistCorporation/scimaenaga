# frozen_string_literal: true

require "spec_helper"

describe ScimPatchOperation do

  let(:op) { 'Replace' }
  let(:path) { 'userName' }
  let(:value) { 'taro.suzuki' }
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
      }
    }
  }
  let(:operation) {
    described_class.new(
      op,
      path,
      value,
      mutable_attributes_schema
    )
  }
  describe '#initialize' do
    context 'replace single attribute' do
      it {
        expect(operation.op).to eq :replace
        expect(operation.path_scim).to eq path
        expect(operation.path_sp).to eq :name
        expect(operation.value).to eq value
      }
    end

    context 'add single attribute' do
      let(:op) { 'Add' }
      it {
        expect(operation.op).to eq :add
        expect(operation.path_scim).to eq path
        expect(operation.path_sp).to eq :name
        expect(operation.value).to eq value
      }
    end

    context 'remove single attribute' do
      let(:op) { 'Remove' }
      it {
        expect(operation.op).to eq :remove
        expect(operation.path_scim).to eq path
        expect(operation.path_sp).to eq :name
        expect(operation.value).to eq value
      }
    end

    context 'replace email address' do
      let(:path) { 'emails[type eq "work"].value' }
      let(:value) { 'taro.suzuki@example.com' }
      it {
        expect(operation.op).to eq :replace
        expect(operation.path_scim).to eq path
        expect(operation.path_sp).to eq :email
        expect(operation.value).to eq value
      }
    end

    context 'replace name.familyName' do
      let(:path) { 'name.familyName' }
      let(:value) { 'Suzuki' }
      it {
        expect(operation.op).to eq :replace
        expect(operation.path_scim).to eq path
        expect(operation.path_sp).to eq :family_name
        expect(operation.value).to eq value
      }
    end
  end

end