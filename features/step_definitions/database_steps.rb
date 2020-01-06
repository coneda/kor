Given /^the credential "([^\"]*)"$/ do |name|
  step "the credential \"#{name}\" described by \"\""
end

Given /^the credential "([^\"]*)" described by "([^\"]*)"$/ do |name, description|
  unless Credential.exists? :name => name
    Credential.create :name => name, :description => description
  end
end

Given /^the collection "([^\"]*)"$/ do |name|
  unless Collection.exists? :name => name
    Collection.create! :name => name
  end
end

Given /^the kind "([^\"]*)"(?: inheriting from "([^\"]*)")?$/ do |names, parents|
  components = names.split('/')
  singular = components[0..(components.size / 2 - 1)].join('/')
  plural = components[(components.size / 2)..-1].join('/')
  kind = Kind.find_or_initialize_by(:name => singular, :plural_name => plural)
  if parents.present?
    parents.split(',').each do |parent|
      kind.parents << Kind.find_by(name: parent)
    end
  end
  kind.save
end

Given(/^the generator "(.*?)" for kind "(.*?)"$/) do |name, kind_name|
  step "the kind \"#{kind_name}\""
  generator = FactoryGirl.build name
  kind = Kind.find_by(name: kind_name.split('/').first)
  kind.generators << generator
  kind.save
end

Given /^the relation "([^\"]*)" inheriting from "([^\"]*)"?$/ do |names, parents|
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

Given /^the medium "([^"]*)"$/ do |path|
  step "I go to the new \"Medium-Entity\" page"
  step "I attach the file \"#{path}\" to \"entity[medium_attributes][document]\""
  step "I press \"Create\""
end

Given /^the medium "(.*?)" inside collection "(.*?)"$/ do |file, collection|
  collection = Collection.find_by_name(collection)
  entity = collection.entities.build :kind => Kind.first
  entity.build_medium :document => File.open("#{Rails.root}/#{file}")
  
  unless entity.save
    p entity.errors.full_messages
  end
end

Given /^the entity "([^\"]*)" of kind "([^\"]*)"$/ do |name, kind|
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

Then /^entity "([^"]*)" should have dataset value "([^"]*)" for "([^"]*)"$/ do |entity, value, name|
  entity = Entity.find_by_name entity
  expect(entity.dataset[name]).to eq(value  )
end

Given(/^the entity "(.*?)" has property "(.*?)" with value "(.*?)"$/) do |entity, label, value|
  entity = Entity.find_by_name entity
  entity.properties << {'label' => label, 'value' => value}
  entity.save
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

Given(/^"([^"]*)" are allowed to "([^"]*)" collection "([^"]*)"$/) do |credential, policy, collection|
  step "the collection \"#{collection}\""
  step "the credential \"#{credential}\""

  collection = Collection.find_by_name(collection)
  credential = Credential.find_by_name(credential)

  policy.split("/").each do |p|
    Kor::Auth.grant collection, p, :to => credential
  end
end

Given /^user "([^"]*)" is a "([^"]*)"$/ do |user, role|
  User.find_by_name(user).update_attributes role.to_sym => true
end

Given /^the (invalid )?entity "([^"]*)" of kind "([^"]*)" inside collection "([^"]*)"$/ do |invalid, entity, kind, collection|
  step "the entity \"#{entity}\" of kind \"#{kind}\""
  step "the collection \"#{collection}\""
  entity = Entity.find_by_name(entity)
  collection = Collection.find_by_name(collection)
  entity.update_attributes :collection_id => collection.id
  entity.mark_invalid if invalid == "invalid "
end

Given /^(\d+) (invalid )?entities "([^\"]*)" of kind "([^\"]*)" inside collection "([^\"]*)"$/ do |count, invalid, entity, kind, collection|
  count.to_i.times do |i|
    step "the #{invalid}entity \"#{entity}_#{i}\" of kind \"#{kind}\" inside collection \"#{collection}\""
  end
end

Given /^the entity "([^"]*)" has the synonyms "([^"]*)"$/ do |entity, synonyms|
  Entity.find_by_name(entity).update_attributes :synonyms => synonyms.split('/')
end

Given /^"([^\"]*)" has a (shared )?user group "([^\"]*)"$/ do |user_name, shared, group_name|
  User.find_by_name!(user_name).user_groups.create!(
    name: group_name,
    shared: shared == 'shared '
  )
end

Given /^the authority group "([^"]*)"(?: inside "([^"]+)")?$/ do |name, category_name|
  group = AuthorityGroup.create :name => name
  if category_name
    AuthorityGroupCategory.find_by_name(category_name).authority_groups << group
  end
end

Given /^the authority group "([^"]*)" contains a medium$/ do |name|
  step "Mona Lisa and a medium as correctly related entities"
  
  AuthorityGroup.find_by_name(name).add_entities Medium.first.entity
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

Given /^the (shared )?user group "([^\"]*)"( published as "[^\"]*")?$/ do |shared, name, pub|
  unless UserGroup.find_by_name(name)
    step "I am on the user groups page"
    step "I follow \"Plus\""
    step "I fill in \"user_group[name]\" with \"#{name}\""
    step "I press \"Create\""
    
    if shared == 'shared '
      step "I follow \"Private\""
    end
    
    unless pub.blank?
      pub_name = pub.gsub(/.*\"([^\"]+)\".*/, "\\1")
    
      step "I go to the publishments page"
      step "I follow \"Plus\""
      step "I fill in \"publishment[name]\" with \"#{pub_name}\""
      step "I select \"#{name}\" from \"publishment[user_group_id]\""
      step "I press \"Create\""
    end
  end
end

Given(/^the entity "([^"]*)" is in authority group "([^"]*)"$/) do |entity, group|
  entity = Entity.find_by(name: entity)
  ag = AuthorityGroup.find_by(name: group)
  ag.entities << entity
  ag.save
end

Then /^there should be "([^"]*)" "([^"]*)" entity in the database$/ do |num, kind|
  expect(Kind.find_by_name(kind).entities.count).to eql(num.to_i)
end

Then /^there should( not)? be the collection named "([^\"]*)" in the database$/ do |reverse, name|
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

Given /^the triple "([^\"]*)" "([^\"]*)" "([^\"]*)" "([^\"]*)" "([^\"]*)"$/ do |from_kind, from_name, relation, to_kind, to_name|
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

Given /^the relationship "([^\"]*)" "([^\"]*)" "([^\"]*)"(?: with properties "([^\"]*)")?$/ do |from, name, to, props|
  from = Entity.find_by_name(from)
  to = Entity.find_by_name(to)
  props = (props || "").split("/")
  
  name = name.split("/").first
  step "the relation \"#{name}\" between \"#{from.kind.name}/#{from.kind.plural_name}\" and \"#{to.kind.name}/#{to.kind.plural_name}\""
  
  Relationship.relate_and_save(from, name, to, props)
end

Given /^the relationship "(.*?)" "(.*?)" the last medium$/ do |from, name|
  from = Entity.find_by_name(from)
  to = Medium.last.entity
  
  name = name.split("/").first
  step "the relation \"#{name}\" between \"#{from.kind.name}/#{from.kind.plural_name}\" and \"#{to.kind.name}/#{to.kind.plural_name}\""
  
  Relationship.relate_and_save(from, name, to)
end

Given /^there are "([^"]*)" entities named "([^"]*)" of kind "([^"]*)"$/ do |num, name_pattern, kind|
  step "the kind \"#{kind}\""
  
  kind = Kind.find_by_name(kind.split('/').first)
  
  num.to_i.times do |i|
    kind.entities.create(
      :collection => Collection.first,
      :name => name_pattern.gsub("X", i.to_s)
    )
  end
end

Given /^Mona Lisa and a medium as correctly related entities$/ do
  step "the relation \"is shown by/shows\" between \"work/works\" and \"medium/media\""
  step "the entity \"Mona Lisa\" of kind \"work/works\""
  step "the medium \"spec/fixtures/image_a.jpg\""
  
  medium = Kind.medium_kind.entities.first
  mona_lisa = Entity.find_by_name('Mona Lisa')
  
  Relationship.relate_and_save(mona_lisa, "is shown by", medium)
end

Given /^Leonardo, Mona Lisa and a medium as correctly related entities$/ do
  step "Mona Lisa and a medium as correctly related entities"
  step "the relation \"has created/has been created by\" between \"person/people\" and \"work/works\""
  step "the entity \"Leonardo da Vinci\" of kind \"person/people\""

  leonardo = Entity.find_by_name('Leonardo da Vinci')
  mona_lisa = Entity.find_by_name('Mona Lisa')

  Relationship.relate_and_save(leonardo, "has created", mona_lisa)
end

Given /^the entity "([^\"]*)" has ([0-9]+) relationships$/ do |name, amount|
  entity = Entity.find_by_name(name)
  step "the entity \"Test Entity\" of kind \"#{entity.kind.name}/#{entity.kind.plural_name}\""
  test_entity = Entity.find_by_name("Test Entity")
  step "the relation \"ist äquivalent zu/ist äquivalent zu\" between \"#{entity.kind.name}\" and \"#{test_entity.kind.name}\""

  amount.to_i.times do
    Relationship.relate_and_save(entity, "ist äquivalent zu", test_entity, ['Zusatzinformation'])
  end
  
  Relationship.last.update_attributes :properties => ['ENDE']
end

Given(/^kind "(.*?)" has web service "(.*?)"$/) do |kind_name, web_service_name|
  kind = Kind.where(:name => kind_name).first
  kind.settings[:web_services] ||= []
  kind.settings[:web_services] << web_service_name
  kind.save
end

Then(/^user "(.*?)" should (not )?be active$/) do |email, n|
  user = User.where(:email => email).first
  if n == "not "
    expect(user.active).to be_falsey
  else
    expect(user.active).to be_truthy
  end
end

Then(/^user "(.*?)" should (not )?have the role "(.*?)"$/) do |email, n, role|
  user = User.where(:email => email).first
  if n == "not "
    expect(user.send role.to_sym).to be_falsey
  else
    expect(user.send role.to_sym).to be_truthy
  end
end

Then(/^user "(.*?)" should expire at "(.*?)"$/) do |email, time_str|
  user = User.where(:email => email).first
  time = eval(time_str, binding)
  expect(user.expires_at).to be_within(1.minute).of(time)
end

Then(/^user "(.*?)" should not expire$/) do |email|
  expect(User.where(:email => email).first.expires_at).to be_nil
end

Given(/^the last entity has the tags "(.*?)"$/) do |tag_list|
  Entity.last.update_attributes :tag_list => tag_list
end

Given(/^the entity "([^"]*)" was created by "([^"]*)"$/) do |name, username|
  entity = Entity.where(name: 'Mona Lisa').first
  user = User.where(name: username).first
  entity.update_attributes creator: user
end

Given(/^the entity "([^"]*)" was updated by "([^"]*)"$/) do |name, username|
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

Given(/^the kind "([^"]*)" has identifier "([^"]*)" labelled "([^"]*)"$/) do |kind, field, label|
  kind = Kind.find_by(name: kind)
  kind.fields << Field.create(name: field, show_label: label, is_identifier: true)
end

Given(/^tagging is activated for kind "([^"]*)"$/) do |name|
  kind = Kind.find_by(name: name)
  binding.pry
end

Given(/^the relationship has a dating "([^"]*)"$/) do |dating|
  l, ds = dating.split('|')
  Relationship.last.update_attributes(
    datings_attributes: [{label: l, dating_string: ds}]
  )
end

Given(/^entity "([^"]*)" has dating "([^"]*)"$/) do |name, dating|
  label, value = dating.split(/: ?/)
  Entity.find_by(name: name).datings.create label: label, dating_string: value
end

Then(/^entity "([^"]*)" should (not )?have dating "([^"]*)"$/) do |name, negation, dating|
  label, value = dating.split(/: ?/)
  result = Entity.find_by(name: name).datings.any? do |d|
    d.label == label && d.dating_string == value
  end

  if negation
    expect(result).to be_falsey
  else
    expect(result).to be_truthy
  end
end

Given(/^the user "([^"]*)" has not accepted the terms of use$/) do |name|
  User.find_by!(name: name).update terms_accepted: false
end