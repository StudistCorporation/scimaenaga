require 'spec_helper'

describe Scimaenaga::Encoder do
  let(:company) { Company.new(subdomain: 'test') }

  describe '::encode' do
    context 'with signing configuration' do
      it 'generates a signed token with the company attribute' do
        token   = Scimaenaga::Encoder.encode(company)
        payload = Scimaenaga::Encoder.decode(token)

        expect(token).to match(/[a-z|A-Z0-9.]{16,}\.[a-z|A-Z0-9.]{16,}/)
        expect(payload).to contain_exactly(['iat', Integer], %w[subdomain test])
      end
    end

    context 'without signing configuration' do
      before do
        allow(Scimaenaga.config).to receive(:signing_secret).and_return(nil)
        allow(Scimaenaga.config).to receive(:signing_algorithm).and_return(Scimaenaga::Config::ALGO_NONE)
      end

      it 'generates an unsigned token with the company attribute' do
        token   = Scimaenaga::Encoder.encode(company)
        payload = Scimaenaga::Encoder.decode(token)

        expect(token).to match(/[a-z|A-Z0-9.]{16,}/)
        expect(payload).to contain_exactly(['iat', Integer], %w[subdomain test])
      end
    end
  end

  describe '::decode' do
    let(:token) { Scimaenaga::Encoder.encode(company) }

    it 'raises InvalidCredentials error for an invalid token' do
      token = 'f487bf84bfub4f74fj4894fnh483f4h4u8f'
      expect do
        Scimaenaga::Encoder.decode(token)
      end.to raise_error Scimaenaga::ExceptionHandler::InvalidCredentials
    end

    context 'with signing configuration' do
      it 'decodes a signed token, returning the company attributes' do
        payload = Scimaenaga::Encoder.decode(token)

        expect(payload).to contain_exactly(['iat', Integer], %w[subdomain test])
      end
    end

    context 'without signing configuration' do
      before do
        allow(Scimaenaga.config).to receive(:signing_secret).and_return(nil)
        allow(Scimaenaga.config).to receive(:signing_algorithm).and_return(Scimaenaga::Config::ALGO_NONE)
      end

      it 'decodes an unsigned token, returning the company attributes' do
        payload = Scimaenaga::Encoder.decode(token)

        expect(payload).to contain_exactly(['iat', Integer], %w[subdomain test])
      end
    end
  end
end
