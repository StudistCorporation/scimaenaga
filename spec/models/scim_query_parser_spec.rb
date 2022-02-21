# frozen_string_literal: true

require 'spec_helper'

describe ScimRails::ScimQueryParser do
  let(:query_string) { 'userName eq "taro"' }
  let(:queryable_attributes) do
    {
      userName: :name,
      emails: [
        {
          value: :email,
        }
      ],
    }
  end
  let(:parser) { described_class.new(query_string, queryable_attributes) }

  describe '#attribute' do
    context 'userName' do
      it { expect(parser.attribute).to eq :name }
    end

    context 'emails[type eq "work"].value' do
      let(:query_string) { 'emails[type eq "work"].value eq "taro@example.com"' }
      it { expect(parser.attribute).to eq :email }
    end
  end
end
