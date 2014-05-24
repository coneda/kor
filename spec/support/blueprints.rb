Collection.blueprint do
  name "Default"
end

Kind.blueprint do

end

ExceptionLog.blueprint do

end

Grant.blueprint do

end

Entity.blueprint do
  collection { Collection.find_by_name('Default') }
  kind
end

Entity.blueprint(:medium) do
  kind { Kind.medium_kind }
end

Entity.blueprint(:person) do
  name {"Leonardo da Vinci"}
  kind { Kind.find_by_name 'Person' }
end

Entity.blueprint(:mona_lisa) do
  name { "Mona Lisa" }
  kind { Kind.find_by_name 'Werk' }
end

Medium.blueprint do
  document { File.open("#{Rails.root}/spec/fixtures/image_a.jpg") }
end

Medium.blueprint(:a) do
  document { File.open("#{Rails.root}/spec/fixtures/image_a.jpg") }
end

Medium.blueprint(:b) do
  document { File.open("#{Rails.root}/spec/fixtures/image_b.jpg") }
end

Medium.blueprint(:c) do
  document { File.open("#{Rails.root}/spec/fixtures/image_c.jpg") }
end

EntityDating.blueprint do
  label {"Datierung"}
  dating_string {"1566"}
end

User.blueprint do
  name { Faker::Internet.user_name }
  password { name }
  full_name { Faker::Name.name }
  email { Faker::Internet.email }
  terms_accepted true
end

User.blueprint(:admin) do
  name 'admin'
  password 'admin'
  full_name 'Administrator'
  email 'admin@localhost'
  
  admin true
  user_admin true
  relation_admin true
  kind_admin true
  collection_admin true
  credential_admin true
  authority_group_admin true
  developer true
end

Credential.blueprint do
  name "users"
end

Relation.blueprint do
  name
  reverse_name
end

AuthorityGroup.blueprint do
  name {"Test Group"}
end

AuthorityGroupCategory.blueprint do
  
end

AuthorityGroupCategory.blueprint(:A) do
  name 'A'
end

AuthorityGroupCategory.blueprint(:B) do
  name 'B'
end

AuthorityGroupCategory.blueprint(:C) do
  name 'C'
end

AuthorityGroupCategory.blueprint(:BA) do
  name 'BA'
end

AuthorityGroupCategory.blueprint(:BB) do
  name 'BB'
end

AuthorityGroupCategory.blueprint(:BAA) do
  name 'BAA'
end

AuthorityGroupCategory.blueprint(:BAB) do
  name 'BAB'
end

UserGroup.blueprint do
  name {"Test Group"}
  owner {User.admin}
end

SystemGroup.blueprint do
  name
end
