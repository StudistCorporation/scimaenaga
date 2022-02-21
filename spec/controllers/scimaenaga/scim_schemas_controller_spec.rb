# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Scimaenaga::ScimSchemasController, type: :controller do
  include AuthHelper

  routes { Scimaenaga::Engine.routes }

  let(:schemas) do
    [
      {
        schemas: ['urn:ietf:params:scim:schemas:core:2.0:Schema'],
        id: 'urn:ietf:params:scim:schemas:core:2.0:User',
        name: 'User',
        description: 'User Account',
        attributes: [
          {
            name: 'userName',
            type: 'string',
            multiValued: false,
            description: 'Unique identifier for the User. REQUIRED.',
            required: true,
            caseExact: false,
            mutability: 'readWrite',
            returned: 'default',
            uniqueness: 'server',
          }
        ],
        meta: {
          resourceType: 'Schema',
          location:
            '/v2/Schemas/urn:ietf:params:scim:schemas:core:2.0:User',
        },
      },
      {
        schemas: ['urn:ietf:params:scim:schemas:core:2.0:Schema'],
        id: 'urn:ietf:params:scim:schemas:core:2.0:Group',
        name: 'Group',
        description: 'Group',
        attributes: [
          {
            name: 'displayName',
            type: 'string',
            multiValued: false,
            description: 'A human-readable name for the Group. REQUIRED.',
            required: false,
            caseExact: false,
            mutability: 'readWrite',
            returned: 'default',
            uniqueness: 'none',
          }
        ],
        meta: {
          resourceType: 'Schema',
          location: '/v2/Schemas/urn:ietf:params:scim:schemas:core:2.0:Group',
        },
      }
    ]
  end

  let(:schemas_110) do
    [
      { id: 'dummy1' }, { id: 'dummy2' }, { id: 'dummy3' },
      { id: 'dummy4' }, { id: 'dummy5' }, { id: 'dummy6' },
      { id: 'dummy7' }, { id: 'dummy8' }, { id: 'dummy9' },
      { id: 'dummy10' }, { id: 'dummy11' }, { id: 'dummy12' },
      { id: 'dummy13' }, { id: 'dummy14' }, { id: 'dummy15' },
      { id: 'dummy16' }, { id: 'dummy17' }, { id: 'dummy18' },
      { id: 'dummy19' }, { id: 'dummy20' }, { id: 'dummy21' },
      { id: 'dummy22' }, { id: 'dummy23' }, { id: 'dummy24' },
      { id: 'dummy25' }, { id: 'dummy26' }, { id: 'dummy27' },
      { id: 'dummy28' }, { id: 'dummy29' }, { id: 'dummy30' },
      { id: 'dummy31' }, { id: 'dummy32' }, { id: 'dummy33' },
      { id: 'dummy34' }, { id: 'dummy35' }, { id: 'dummy36' },
      { id: 'dummy37' }, { id: 'dummy38' }, { id: 'dummy39' },
      { id: 'dummy40' }, { id: 'dummy41' }, { id: 'dummy42' },
      { id: 'dummy43' }, { id: 'dummy44' }, { id: 'dummy45' },
      { id: 'dummy46' }, { id: 'dummy47' }, { id: 'dummy48' },
      { id: 'dummy49' }, { id: 'dummy50' }, { id: 'dummy51' },
      { id: 'dummy52' }, { id: 'dummy53' }, { id: 'dummy54' },
      { id: 'dummy55' }, { id: 'dummy56' }, { id: 'dummy57' },
      { id: 'dummy58' }, { id: 'dummy59' }, { id: 'dummy60' },
      { id: 'dummy61' }, { id: 'dummy62' }, { id: 'dummy63' },
      { id: 'dummy64' }, { id: 'dummy65' }, { id: 'dummy66' },
      { id: 'dummy67' }, { id: 'dummy68' }, { id: 'dummy69' },
      { id: 'dummy70' }, { id: 'dummy71' }, { id: 'dummy72' },
      { id: 'dummy73' }, { id: 'dummy74' }, { id: 'dummy75' },
      { id: 'dummy76' }, { id: 'dummy77' }, { id: 'dummy78' },
      { id: 'dummy79' }, { id: 'dummy80' }, { id: 'dummy81' },
      { id: 'dummy82' }, { id: 'dummy83' }, { id: 'dummy84' },
      { id: 'dummy85' }, { id: 'dummy86' }, { id: 'dummy87' },
      { id: 'dummy88' }, { id: 'dummy89' }, { id: 'dummy90' },
      { id: 'dummy91' }, { id: 'dummy92' }, { id: 'dummy93' },
      { id: 'dummy94' }, { id: 'dummy95' }, { id: 'dummy96' },
      { id: 'dummy97' }, { id: 'dummy98' }, { id: 'dummy99' },
      { id: 'dummy100' }, { id: 'dummy101' }, { id: 'dummy102' },
      { id: 'dummy103' }, { id: 'dummy104' }, { id: 'dummy105' },
      { id: 'dummy106' }, { id: 'dummy107' }, { id: 'dummy108' },
      { id: 'dummy109' }, { id: 'dummy110' }
    ]
  end

  describe 'index' do
    let(:company) { create(:company) }

    context 'when unauthorized' do
      it 'returns scim+json content type' do
        get :index, as: :json

        expect(response.media_type).to eq 'application/scim+json'
      end

      it 'fails with no credentials' do
        get :index, as: :json

        expect(response.status).to eq 401
      end

      it 'fails with invalid credentials' do
        request.env['HTTP_AUTHORIZATION'] =
          ActionController::HttpAuthentication::Basic
          .encode_credentials('unauthorized', '123456')

        get :index, as: :json

        expect(response.status).to eq 401
      end
    end

    context 'when authorized' do
      before :each do
        http_login(company)
      end

      it 'returns scim+json content type' do
        get :index, as: :json

        expect(response.media_type).to eq 'application/scim+json'
      end

      it 'is successful with valid credentials' do
        get :index, as: :json

        expect(response.status).to eq 200
      end

      it 'returns all results' do
        allow(Scimaenaga.config).to(receive(:schemas).and_return(schemas))
        get :index, as: :json
        response_body = JSON.parse(response.body)
        expect(response_body.dig('schemas', 0)).to(
          eq 'urn:ietf:params:scim:api:messages:2.0:ListResponse'
        )
        expect(response_body['totalResults']).to eq 2
      end

      it 'defaults to 100 results' do
        allow(Scimaenaga.config).to(receive(:schemas).and_return(schemas_110))

        get :index, as: :json
        response_body = JSON.parse(response.body)
        expect(response_body['totalResults']).to eq 110
        expect(response_body['startIndex']).to eq 1
        expect(response_body['Resources'].count).to eq 100
      end

      it 'paginates results' do
        allow(Scimaenaga.config).to(receive(:schemas).and_return(schemas_110))
        get :index, params: {
          startIndex: 101,
          count: 5,
        }, as: :json
        response_body = JSON.parse(response.body)
        expect(response_body['totalResults']).to eq 110
        expect(response_body['startIndex']).to eq 101
        expect(response_body['Resources'].count).to eq 5
        expect(response_body.dig('Resources', 0, 'id')).to eq 'dummy101'
      end
    end
  end

  describe 'show' do
    let(:company) { create(:company) }

    context 'when unauthorized' do
      it 'returns scim+json content type' do
        get :show, params: { id: 1 }, as: :json

        expect(response.media_type).to eq 'application/scim+json'
      end

      it 'fails with no credentials' do
        get :show, params: { id: 1 }, as: :json

        expect(response.status).to eq 401
      end

      it 'fails with invalid credentials' do
        request.env['HTTP_AUTHORIZATION'] =
          ActionController::HttpAuthentication::Basic
          .encode_credentials('unauthorized', '123456')

        get :show, params: { id: 1 }, as: :json

        expect(response.status).to eq 401
      end
    end

    context 'when authorized' do
      before :each do
        http_login(company)
      end

      it 'returns scim+json content type' do
        allow(Scimaenaga.config).to(receive(:schemas).and_return(schemas))
        get :show, params: { id: 'urn:ietf:params:scim:schemas:core:2.0:User' }, as: :json

        expect(response.media_type).to eq 'application/scim+json'
      end

      it 'is successful with valid credentials' do
        allow(Scimaenaga.config).to(receive(:schemas).and_return(schemas))
        get :show, params: { id: 'urn:ietf:params:scim:schemas:core:2.0:User' }, as: :json

        response_body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body['name']).to eq 'User'
      end

      it 'returns :not_found for id that cannot be found' do
        get :show, params: { id: 'fake_id' }, as: :json

        expect(response.status).to eq 404
      end
    end
  end
end
