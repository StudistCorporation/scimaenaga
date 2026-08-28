# frozen_string_literal: true

require 'spec_helper'

describe ScimPatchOperationGroup do
  let(:op) { 'replace' }
  let(:path) { 'displayName' }
  let(:value) { 'groupA' }
  let(:mutable_attributes_schema) { { displayName: :name } }
  let(:group_member_relation_attribute) { :user_ids }

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:user3) { create(:user) }
  let(:user4) { create(:user) }
  let(:group) { create(:group, users: [user1, user2]) }

  let(:operation) do
    described_class.new(
      op,
      path,
      value
    )
  end
  context 'replace displayName' do
    it {
      allow(Scimaenaga.config).to(
        receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
      )
      allow(Scimaenaga.config).to(
        receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
      )
      expect(operation.op).to eq 'replace'
      expect(operation.path_scim).to eq(attribute: path, rest_path: [])
      expect(operation.path_sp).to eq :name
      expect(operation.value).to eq value

      operation.save(group)
      expect(group.name).to eq value
    }
  end

  context 'add displayName' do
    let(:op) { 'add' }
    it {
      allow(Scimaenaga.config).to(
        receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
      )
      allow(Scimaenaga.config).to(
        receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
      )
      expect(operation.op).to eq 'add'
      expect(operation.path_scim).to eq(attribute: path, rest_path: [])
      expect(operation.path_sp).to eq :name
      expect(operation.value).to eq value

      operation.save(group)
      expect(group.name).to eq value
    }
  end

  context 'remove displayName' do
    let(:op) { 'remove' }
    it {
      allow(Scimaenaga.config).to(
        receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
      )
      allow(Scimaenaga.config).to(
        receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
      )
      expect(operation.op).to eq 'remove'
      expect(operation.path_scim).to eq(attribute: path, rest_path: [])
      expect(operation.path_sp).to eq :name
      expect(operation.value).to eq value

      operation.save(group)
      expect(group.name).to eq nil
    }
  end

  context 'add member' do
    let(:op) { 'add' }
    let(:path) { 'members' }
    let(:value) { [{ 'value' => user3.id.to_s }, { 'value' => user4.id.to_s }] }
    it {
      allow(Scimaenaga.config).to(
        receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
      )
      allow(Scimaenaga.config).to(
        receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
      )
      expect(operation.op).to eq 'add'
      expect(operation.path_scim).to eq(attribute: 'members', rest_path: [])
      expect(operation.path_sp).to eq :user_ids
      expect(operation.value).to eq value

      operation.save(group)
      expect(group.users).to eq [user1, user2, user3, user4]
    }
  end

  context 'replace member' do
    let(:op) { 'replace' }
    let(:path) { 'members' }
    let(:value) { [{ 'value' => user3.id.to_s }, { 'value' => user4.id.to_s }] }
    it {
      allow(Scimaenaga.config).to(
        receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
      )
      allow(Scimaenaga.config).to(
        receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
      )
      expect(operation.op).to eq 'replace'
      expect(operation.path_scim).to eq(attribute: 'members', rest_path: [])
      expect(operation.path_sp).to eq :user_ids
      expect(operation.value).to eq value

      operation.save(group)
      expect(group.users).to eq [user3, user4]
    }
  end

  context 'remove user ids' do
    let(:op) { 'remove' }
    let(:path) { 'members' }
    let(:value) { [{ 'value' => user1.id.to_s }, { 'value' => user2.id.to_s }] }
    it {
      allow(Scimaenaga.config).to(
        receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
      )
      allow(Scimaenaga.config).to(
        receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
      )
      expect(operation.op).to eq 'remove'
      expect(operation.path_scim).to eq(attribute: 'members', rest_path: [])
      expect(operation.path_sp).to eq :user_ids
      expect(operation.value).to eq value

      operation.save(group)
      expect(group.users).to eq []
    }
  end

  describe '#member_ids_to_assign' do
    let(:path) { 'members' }
    let(:value) { [{ 'value' => user3.id.to_s }, { 'value' => user4.id }] }

    before do
      allow(Scimaenaga.config).to(
        receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
      )
      allow(Scimaenaga.config).to(
        receive(:group_member_relation_attribute)
          .and_return(group_member_relation_attribute)
      )
    end

    context 'add members' do
      let(:op) { 'add' }
      it { expect(operation.member_ids_to_assign).to eq [user3.id.to_s, user4.id.to_s] }
    end

    context 'replace members' do
      let(:op) { 'replace' }
      it { expect(operation.member_ids_to_assign).to eq [user3.id.to_s, user4.id.to_s] }
    end

    context 'remove members' do
      let(:op) { 'remove' }
      it { expect(operation.member_ids_to_assign).to eq [] }
    end

    context 'path is not members' do
      let(:op) { 'replace' }
      let(:path) { 'displayName' }
      let(:value) { 'groupA' }
      it { expect(operation.member_ids_to_assign).to eq [] }
    end

    context 'value is nil' do
      let(:op) { 'add' }
      let(:value) { nil }
      it { expect(operation.member_ids_to_assign).to eq [] }
    end

    context 'value is not an array' do
      let(:op) { 'add' }
      let(:value) { user3.id.to_s }
      it { expect(operation.member_ids_to_assign).to eq [] }
    end
  end

  context 'remove user id (with filter)' do
    let(:op) { 'remove' }
    let(:path) { "members[value eq \"#{user1.id}\"]" }
    let(:value) { nil }
    it {
      allow(Scimaenaga.config).to(
        receive(:mutable_group_attributes_schema).and_return(mutable_attributes_schema)
      )
      allow(Scimaenaga.config).to(
        receive(:group_member_relation_attribute).and_return(group_member_relation_attribute)
      )
      expect(operation.op).to eq 'remove'
      expect(operation.path_scim).to eq(attribute: 'members',
                                        filter: { attribute: 'value', operator: 'eq', parameter: user1.id.to_s }, rest_path: [])
      expect(operation.path_sp).to eq :user_ids
      expect(operation.value).to eq nil

      operation.save(group)
      expect(group.users).to eq [user2]
    }
  end
end
