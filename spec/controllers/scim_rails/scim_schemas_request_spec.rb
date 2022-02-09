# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ScimRails::ScimSchemasController, type: :request do
  let(:company) { create(:company) }
  let(:credentials) do
    Base64.encode64("#{company.subdomain}:#{company.api_token}")
  end
  let(:authorization) { "Basic #{credentials}" }

  def get_request(content_type = 'application/scim+json')
    get '/scim/v2/Schemas',
        headers: {
          Authorization: authorization,
          'Content-Type': content_type,
        }
  end

  context 'OAuth Bearer Authorization' do
    context 'with valid token' do
      let(:authorization) { "Bearer #{company.api_token}" }

      it 'supports OAuth bearer authorization and succeeds' do
        get_request
        expect(response.status).to eq 200
      end
    end

    context 'with invalid token' do
      let(:authorization) { "Bearer #{SecureRandom.hex}" }

      it 'The request fails' do
        get_request
        expect(response.status).to eq 401
      end
    end
  end
end
