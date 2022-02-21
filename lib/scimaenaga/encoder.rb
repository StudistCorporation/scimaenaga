require 'jwt'

module Scimaenaga
  module Encoder
    extend self

    def encode(company)
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
  end
end
