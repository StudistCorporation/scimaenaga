# frozen_string_literal: true

require 'spec_helper'

describe ScimPatchOperationGroup do
  let(:op) { 'replace' }
  let(:path) { 'displayName' }
  let(:value) { 'groupA' }
  let(:mutable_attributes_schema) { { displayName: :name } }
  let(:group_member_relation_attribute) { :user_ids }

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
        allow(ScimRails.config).to(
          receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
        )
        allow(ScimRails.config).to(
          receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
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
        allow(ScimRails.config).to(
          receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
        )
        allow(ScimRails.config).to(
          receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
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
        allow(ScimRails.config).to(
          receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
        )
        allow(ScimRails.config).to(
          receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
        )
        expect(operation.op).to eq 'remove'
        expect(operation.path_scim).to eq(attribute: path, rest_path: [])
        expect(operation.path_sp).to eq :name
        expect(operation.value).to eq value
      }
    end

    context 'add user ids' do
      let(:op) { 'add' }
      let(:path) { 'members' }
      let(:value) { [{ 'value' => '1' }, { 'value' => '2' }] }
      it {
        allow(ScimRails.config).to(
          receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
        )
        allow(ScimRails.config).to(
          receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
        )
        expect(operation.op).to eq 'add'
        expect(operation.path_scim).to eq(attribute: 'members', rest_path: [])
        expect(operation.path_sp).to eq :user_ids
        expect(operation.value).to eq value
      }
    end

    # TODO: operation.value should be ['1', '2']
    xcontext 'remove user ids' do
      let(:op) { 'remove' }
      let(:path) { 'members' }
      let(:value) { [{ 'value' => '1' }, { 'value' => '2' }] }
      it {
        allow(ScimRails.config).to(
          receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
        )
        allow(ScimRails.config).to(
          receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
        )
        expect(operation.op).to eq 'remove'
        expect(operation.path_scim).to eq(attribute: 'members', rest_path: [])
        expect(operation.path_sp).to eq :user_ids
        expect(operation.value).to eq %w[1 2]
      }
    end

    # TODO: operation.value should be ['abcdef01']
    xcontext 'remove user id (with filter)' do
      let(:op) { 'remove' }
      let(:path) { 'members[value eq "abcdef01"]' }
      let(:value) { nil }
      it {
        allow(ScimRails.config).to(
          receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
        )
        allow(ScimRails.config).to(
          receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
        )
        expect(operation.op).to eq 'remove'
        expect(operation.path_scim).to eq(attribute: 'members',
                                          filter: { attribute: 'value', operator: 'eq', parameter: 'abcdef01' }, rest_path: [])
        expect(operation.path_sp).to eq :user_ids
        expect(operation.value).to eq ['abcdef01']
      }
    end
  end
end
