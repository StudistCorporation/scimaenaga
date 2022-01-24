# frozen_string_literal: true

require 'spec_helper'

describe ScimPatchOperation do
  let(:op) { 'Replace' }
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
      value,
      mutable_attributes_schema
    )
  end
  describe '#initialize' do
    context 'replace single attribute' do
      it {
        expect(operation.operations[0].op).to eq :replace
        expect(operation.operations[0].path_scim).to eq path
        expect(operation.operations[0].path_sp).to eq :name
        expect(operation.operations[0].value).to eq value
      }
    end

    context 'add single attribute' do
      let(:op) { 'Add' }
      it {
        expect(operation.operations[0].op).to eq :add
        expect(operation.operations[0].path_scim).to eq path
        expect(operation.operations[0].path_sp).to eq :name
        expect(operation.operations[0].value).to eq value
      }
    end

    context 'remove single attribute' do
      let(:op) { 'Remove' }
      it {
        expect(operation.operations[0].op).to eq :remove
        expect(operation.operations[0].path_scim).to eq path
        expect(operation.operations[0].path_sp).to eq :name
        expect(operation.operations[0].value).to eq value
      }
    end

    context 'replace email address' do
      let(:path) { 'emails[type eq "work"].value' }
      let(:value) { 'taro.suzuki@example.com' }
      it {
        expect(operation.operations[0].op).to eq :replace
        expect(operation.operations[0].path_scim).to eq path
        expect(operation.operations[0].path_sp).to eq :email
        expect(operation.operations[0].value).to eq value
      }
    end

    context 'replace name.familyName' do
      let(:path) { 'name.familyName' }
      let(:value) { 'Suzuki' }
      it {
        expect(operation.operations[0].op).to eq :replace
        expect(operation.operations[0].path_scim).to eq path
        expect(operation.operations[0].path_sp).to eq :family_name
        expect(operation.operations[0].value).to eq value
      }
    end

    context 'replace active' do
      let(:path) { 'active' }
      let(:value) { 'False' }

      it 'convert string to bool' do
        expect(operation.operations[0].value).to eq false
      end
    end

    context 'replace multiple attribute' do
      let(:path) { nil }
      let(:value) do
        {
          'userName' => 'taro.suzuki',
          'displayName' => 'Taro Suzuki',
        }
      end

      it 'parse multiple value' do
        expect(operation.operations[0].op).to eq :replace
        expect(operation.operations[0].path_scim).to eq 'userName'
        expect(operation.operations[0].path_sp).to eq :name
        expect(operation.operations[0].value).to eq 'taro.suzuki'

        expect(operation.operations[1].op).to eq :replace
        expect(operation.operations[1].path_scim).to eq 'displayName'
        expect(operation.operations[1].path_sp).to eq :display_name
        expect(operation.operations[1].value).to eq 'Taro Suzuki'
      end
    end
  end
end
