Given /^the credential "([^"]*)"$/ do |name|
  step "the credential \"#{name}\" described by \"\""
end

Given /^the credential "([^"]*)" described by "([^"]*)"$/ do |name, description|
  unless Credential.exists? :name => name
    Credential.create :name => name, :description => description
  end
end

Given /^the collection "([^"]*)"$/ do |name|
  unless Collection.exists? :name => name
    Collection.create! :name => name
  end
end

Given /^the kind "([^"]*)"(?: inheriting from "([^"]*)")?$/ do |names, parents|
  components = names.split('/')
  to = (components.size / 2) - 1
  singular = components[0..to].join('/')
  plural = components[(components.size / 2)..-1].join('/')
  kind = Kind.find_or_initialize_by(:name => singular, :plural_name => plural)
  if parents.present?
    parents.split(',').each do |parent|
      kind.parents << Kind.find_by(name: parent)
    end
  end
  kind.save
end

Given /^the relation "([^"]*)" inheriting from "([^"]*)"?$/ do |names, parents|
  name, reverse = names.split('/')
  reverse = name if reverse.blank?
  relation = Relation.new(
    name: name,
    reverse_name: reverse,
    parents: Relation.where(name: parents.split(','))
  )
  relation.from_kind = relation.parents.first.from_kind
  relation.to_kind = relation.parents.first.to_kind
  relation.save!
end

Given /^the medium "([^"]*)"$/ do |name|
  FactoryGirl.create name.to_sym
end

Given /^the entity "([^"]*)" of kind "([^"]*)"$/ do |name, kind|
  step "the kind \"#{kind}\""
  kind = Kind.find_by_name(kind.split('/').first)

  unless Entity.exists? :name => name
    entity = kind.entities.build(
      :name => name,
      :distinct_name => "",
      :collection => Collection.first
    )
    raise "entity is invalid: #{entity.errors.full_messages.inspect}" unless entity.save
  end
end

Given /^kind "([^"]*)" has field "([^"]*)" of type "([^"]+)"$/ do |kind, name, klass|
  step "the kind \"#{kind}\""
  kind = Kind.find_by_name(kind.split('/').first)
  kind.fields << klass.constantize.new(
    :name => name,
    :show_label => name.classify,
    :form_label => name.classify,
    :search_label => name.classify,
    :settings => {'show_on_entity' => '1'}
  )
end

Given /^the entity "([^"]*)" has dataset value "([^"]*)" for "([^"]*)"$/ do |entity, value, field|
  entity = Entity.find_by_name(entity)
  entity.dataset[field] = value
  entity.save
end

Then /^entity "([^"]*)" should have dataset values? "([^"]*)" for "([^"]*)"$/ do |entity, value, name|
  entity = Entity.find_by_name entity
  value = value.split('|') if value.match(/\|/)
  expect(entity.dataset[name]).to eq(value)
end

Given('field {string} is mandatory') do |name|
  Field.find_by(name: name).update_attributes mandatory: true
end

Given('select field {string} allows the values {string}') do |name, values|
  Field.find_by(name: name).update_attributes values: values.split(/\s*,\s*/)
end

When /^the "([^"]*)" "([^"]*)" is updated behind the scenes$/ do |klass, name|
  item = klass.classify.constantize.find_by_name(name.split('/').first)
  item.update_column :lock_version, item.lock_version + 1
end

Given /^user "([^"]*)" is allowed to "([^"]*)" collection "([^"]*)" (?:through|via)(?: credential)? "([^"]*)"$/ do |user, policy, collection, credential|
  step "the user \"#{user}\""
  step "the collection \"#{collection}\""
  step "the credential \"#{credential}\""

  user = User.find_by_name(user)
  collection = Collection.find_by_name(collection)
  credential = Credential.find_by_name(credential)

  user.groups << credential unless user.groups.include? credential

  policy.split("/").each do |p|
    Kor::Auth.grant collection, p, :to => credential
  end
end

Given /^the (invalid )?entity "([^"]*)" of kind "([^"]*)" inside collection "([^"]*)"$/ do |invalid, entity, kind, collection|
  step "the entity \"#{entity}\" of kind \"#{kind}\""
  step "the collection \"#{collection}\""
  entity = Entity.find_by_name(entity)
  collection = Collection.find_by_name(collection)
  entity.update_attributes :collection_id => collection.id
  entity.mark_invalid if invalid == "invalid "
end

Given /^(\d+) (invalid )?entities "([^"]*)" of kind "([^"]*)" inside collection "([^"]*)"$/ do |count, invalid, entity, kind, collection|
  count.to_i.times do |i|
    step "the #{invalid}entity \"#{entity}_#{i}\" of kind \"#{kind}\" inside collection \"#{collection}\""
  end
end

Given /^the entity "([^"]*)" has the synonyms "([^"]*)"$/ do |entity, synonyms|
  Entity.find_by!(name: entity).update_attributes :synonyms => synonyms.split('/')
end

Given /^"([^"]*)" has a (shared )?user group "([^"]*)"$/ do |user_name, shared, group_name|
  User.find_by!(name: user_name).user_groups.create!(
    name: group_name,
    shared: shared == 'shared '
  )
end

Given /^the authority group "([^"]*)"(?: inside "([^"]+)")?$/ do |name, category_name|
  AuthorityGroup.create!(
    name: name,
    authority_group_category_id: (
      category_name ? AuthorityGroupCategory.find_by!(name: category_name).id : nil
    )
  )
end

Given /^the authority group "([^"]*)" contains a medium$/ do |name|
  # step "Mona Lisa and a medium as correctly related entities"

  AuthorityGroup.find_by!(name: name).add_entities picture_a
end

Given /^the authority group category "([^"]*)"$/ do |name|
  AuthorityGroupCategory.create :name => name
end

Given(/^the first medium is inside user group "(.*?)"$/) do |name|
  UserGroup.where(:name => name).first.entities << Entity.media.first
end

Given /^the authority group categories structure "([^"]*)"$/ do |structure|
  category_names = structure.split(' >> ')

  previous = AuthorityGroupCategory.create :name => category_names.shift
  while current = category_names.shift
    previous = AuthorityGroupCategory.create(:name => current, :parent => previous)
  end
end

Given /^the (shared )?user group "([^"]*)"( published as "[^"]*")?$/ do |shared, name, pub|
  unless UserGroup.find_by_name(name)
    step "I am on the user groups page"
    step "I follow \"create personal group\""
    step "I fill in \"Name\" with \"#{name}\""
    step "I press \"Save\""
    step "I should see \"has been created\""

    if shared == 'shared '
      step "I follow \"share\""
    end

    unless pub.blank?
      pub_name = pub.gsub(/.*"([^"]+)".*/, "\\1")

      step "I go to the publishments page"
      step "I follow \"create published group\""
      step "I fill in \"Name\" with \"#{pub_name}\""
      step "I select \"#{name}\" from \"Personal group\""
      step "I press \"Save\""
    end
  end
end

Given(/^the entity "([^"]*)" is in authority group "([^"]*)"$/) do |entity, group|
  entity = Entity.find_by(name: entity)
  ag = AuthorityGroup.find_by(name: group)
  ag.entities << entity
  ag.save
end

Then /^there should( not)? be the collection named "([^"]*)" in the database$/ do |reverse, name|
  if reverse == ' not'
    expect(Collection.find_by_name name).to be_nil
  else
    expect(Collection.find_by_name name).not_to be_nil
  end
end

Then /^there should be no "([^"]*)" named "([^"]*)"$/ do |model, name|
  expect(model.classify.constantize.find_by_name name).to be_nil
end

Given /^the relation "([^"]*)" between "([^"]*)" and "([^"]*)"$/ do |relation, from_kind, to_kind|
  step "the kind \"#{from_kind}\""
  step "the kind \"#{to_kind}\""

  from_kind = Kind.find_by_name(from_kind.split('/').first)
  to_kind = Kind.find_by_name(to_kind.split('/').first)
  name = relation.split('/').first
  reverse_name = relation.split('/').last
  Relation.find_by(
    from_kind_id: from_kind.id,
    name: name,
    to_kind_id: to_kind.id
  ) || Relation.find_by(
    from_kind_id: to_kind.id,
    reverse_name: name,
    to_kind_id: from_kind.id
  ) || FactoryGirl.create(:relation,
    from_kind_id: from_kind.id,
    name: name,
    reverse_name: reverse_name,
    to_kind_id: to_kind.id
  )
end

Given /^the triple "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)"$/ do |from_kind, from_name, relation, to_kind, to_name|
  step "the relation \"#{relation}\" between \"#{from_kind}\" and \"#{to_kind}\""
  step "the entity \"#{from_name}\" of kind \"#{from_kind}\""
  step "the entity \"#{to_name}\" of kind \"#{to_kind}\""

  relation = relation.split('/').first
  step "the relationship \"#{from_name}\" \"#{relation}\" \"#{to_name}\""
end

Then(/^"(.*?)" should have "(.*?)" "(.*?)"$/) do |subject, relation, object|
  subject = Entity.where(:name => subject).first
  object = Entity.where(:name => object).first

  normal = if normal_relation = Relation.where(:name => relation).first
    Relationship.where(
      :from_id => subject.id,
      :relation_id => normal_relation.id,
      :to_id => object.id
    ).first
  end

  reverse = if reverse_relation = Relation.where(:reverse_name => relation).first
    Relationship.where(
      :from_id => object.id,
      :relation_id => reverse_relation.id,
      :to_id => subject.id
    ).first
  end

  expect(normal || reverse).to be_truthy
end

Given /^the relationship "([^"]*)" "([^"]*)" "([^"]*)"(?: with properties "([^"]*)")?$/ do |from, name, to, props|
  from = Entity.find_by_name(from)
  to = Entity.find_by_name(to)
  props = (props || "").split("/")

  name = name.split("/").first
  step "the relation \"#{name}\" between \"#{from.kind.name}/#{from.kind.plural_name}\" and \"#{to.kind.name}/#{to.kind.plural_name}\""

  Relationship.relate_and_save(from, name, to, props)
end

Given /^there are "([^"]*)" entities named "([^"]*)" of kind "([^"]*)"$/ do |num, name_pattern, kind|
  step "the kind \"#{kind}\""

  kind = Kind.find_by_name(kind.split('/').first)

  num.to_i.times do |i|
    kind.entities.create(
      :collection => Collection.first,
      :name => name_pattern % i
    )
  end
end

Then(/^user "(.*?)" should expire at "(.*?)"$/) do |name, time_str|
  user = User.find_by!(name: name)
  date = eval(time_str, binding).to_date
  expect(user.expires_at.to_date).to eq(date)
end

Given(/^the entity "([^"]*)" was created by "([^"]*)"$/) do |_name, username|
  entity = Entity.where(name: 'Mona Lisa').first
  user = User.where(name: username).first
  entity.update_attributes creator: user
end

Given(/^the entity "([^"]*)" was updated by "([^"]*)"$/) do |_name, username|
  entity = Entity.where(name: 'Mona Lisa').first
  user = User.where(name: username).first
  entity.update_attributes updater: user
end

Given(/^there are "([^"]*)" media entities$/) do |amount|
  amount.to_i.times do |i|
    file = "tmp/test_file.txt"
    system "echo #{i} > #{file}"
    FactoryGirl.create :text, medium: FactoryGirl.build(:medium,
      document: File.open(file)
    )
    system "rm #{file}"
  end
end

Given(/^entity "([^"]*)" has dating "([^"]*)"$/) do |name, dating|
  label, value = dating.split(/: ?/)
  Entity.find_by(name: name).datings.create label: label, dating_string: value
end

Then('entity {string} should have dating {string}') do |name, dating|
  existing = Entity.find_by(name: name).datings.map do |d|
    "#{d.label}: #{d.dating_string}"
  end
  expect(existing).to include(dating)
end

Given("mona lisa has many relationships") do
  10.times do
    Relationship.relate_and_save last_supper, 'is related to', mona_lisa
  end
end

Given("entity {string} is in collection {string}") do |entity, collection|
  entity = Entity.find_by(name: entity)
  collection = Collection.find_by!(name: collection)
  entity.update collection_id: collection.id
end

Given("user {string} is a relation admin") do |name|
  User.find_by!(name: name).update relation_admin: true
end

Then("medium {string} should be in collection {string}") do |medium, collection|
  medium = send(medium.to_sym)
  expect(medium.collection.name).to eq(collection)
end

Then("user {string} should have a personal collection") do |name|
  user = User.find_by!(name: name)
  expect(user.personal_group).to be_present
  expect(user.personal_collection).to be_present
end

Given("user {string} has a personal collection") do |name|
  user = User.find_by!(name: name)
  user.update make_personal: true
end

Given("there are no relations") do
  Relation.destroy_all
end

Then /^user "([^"]*)" should (not )?be active$/ do |name, negation|
  user = User.find_by(name: name)
  if negation
    expect(user).not_to be_active
  else
    expect(user).to be_active
  end
end

Then /^user "([^"]*)" should (not )?have the role "([^"]*)"$/ do |name, negation, role|
  user = User.find_by(name: name)
  result = user.send("#{role}?".to_sym)
  if negation
    expect(result).not_to be_truthy
  else
    expect(result).to be_truthy
  end
end

Then("user {string} should not expire") do |name|
  user = User.find_by(name: name)
  expect(user.expires_at).to be_nil
end

Given("user {string} didn't accept the terms") do |name|
  User.find_by!(name: name).update terms_accepted: false
end

Given("user {string} has locale {string}") do |name, locale|
  User.find_by!(name: name).update_attributes locale: locale
end

Given('the entity {string} is in user group {string}') do |name, group|
  entity = Entity.find_by! name: name
  UserGroup.find_by!(name: group).add_entities(entity)
end

Then('there should be no entity {string}') do |name|
  entity = Entity.find_by name: name
  expect(entity).to be_nil
end

Given('the secondary relationship refers back to the medium') do
  Kor.settings.update(
    'primary_relations' => ['shows'],
    'secondary_relations' => ['is shown by']
  )

  # make sure mona lisa has two related media
  Relationship.relate_and_save picture_b, 'shows', mona_lisa
end
