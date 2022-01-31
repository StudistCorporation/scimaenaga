company = Company.create(
  name: "Test Company",
  subdomain: "test_company",
  api_token: 1
)

group = Group.create(
  company: company,
  name: 'Test Group'
)

User.create(
  company: company,
  first_name: 'scim',
  last_name: 'owner',
  email: 'owner@example.com',
  is_owner: true
)

1.upto(1000) do |n|
  User.create(
    company: company,
    first_name: "Test#{n}",
    last_name: "User#{n}",
    email: "#{n}@example.com",
    is_owner: false
  )
end
