FactoryBot.define do
  factory :company do
    name { 'Test Company' }
    subdomain { 'test' }

    after(:build) do |company|
      company.api_token = Scimaenaga::Encoder.encode(company)
    end
  end
end
