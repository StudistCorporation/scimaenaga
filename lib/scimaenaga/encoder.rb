require 'jwt'

module Scimaenaga
  module Encoder
    extend self

    def encode(company)
      refuse_unsigned_in_production

      payload = {
        iat: Time.current.to_i,
        Scimaenaga.config.basic_auth_model_searchable_attribute =>
          company.public_send(Scimaenaga.config.basic_auth_model_searchable_attribute),
      }

      JWT.encode(payload, Scimaenaga.config.signing_secret,
                 Scimaenaga.config.signing_algorithm)
    end

    def decode(token)
      verify = Scimaenaga.config.signing_algorithm != Scimaenaga::Config::ALGO_NONE

      JWT.decode(token, Scimaenaga.config.signing_secret, verify,
                 algorithm: Scimaenaga.config.signing_algorithm).first
    rescue JWT::VerificationError, JWT::DecodeError
      raise Scimaenaga::ExceptionHandler::InvalidCredentials
    end

    private

      def refuse_unsigned_in_production
        return unless Rails.env.production?

        # The jwt gem also treats "NONE" and :none as "none".
        algorithm = Scimaenaga.config.signing_algorithm.to_s
        return unless algorithm.casecmp?(Scimaenaga::Config::ALGO_NONE)

        raise Scimaenaga::ExceptionHandler::InvalidConfiguration,
              'signing_algorithm must not be "none" in production'
      end
  end
end
