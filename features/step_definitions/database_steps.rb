# encoding: utf-8

# Basics

Given /^there is a user named "([^\"]*)"$/ do |name|
  User.create!(:name => name, :password => name, :email => "#{name}@coneda.net")
end

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

Given /^the kind "([^\"]*)"$/ do |names|
  components = names.split('/')
  singular = components[0..(components.size / 2 - 1)].join('/')
  plural = components[(components.size / 2)..-1].join('/')
  Kind.find_or_create_by_name(:name => singular, :plural_name => plural)
end

Given /^the kinds$/ do |table|
  table.hashes.each do |kind|
    step "the kind \"#{kind[:name]}/#{kind[:plural_name]}\""
  end
end

Given(/^the generator "(.*?)" for kind "(.*?)"$/) do |name, kind_name|
  step "the kind \"#{kind_name}\""
  generator = FactoryGirl.build name
  Kind.where(:name => kind_name.split('/').first).first.generators << generator
end

Given /^the relation "([^\"]*)"$/ do |names|
  name, reverse = names.split('/')
  reverse = name if reverse.blank?
  Relation.create! :name => name, :reverse_name => reverse
end

Given /^the relations$/ do |table|
  table.hashes.each do |relation|
    step "the relation \"#{relation[:name]}/#{relation[:reverse_name]}\""
  end
end

Given /^the unprocessed medium "([^"]*)"$/ do |path|
  step "I go to the new \"Medium-Entity\" page"
  step "I attach the file \"#{path}\" to \"entity[medium_attributes][document]\""
  step "I press \"Erstellen\""
end

Given /^the medium "([^"]*)"$/ do |path|
  step "the unprocessed medium \"#{path}\""
  Delayed::Worker.new.work_off 10
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

Given /^the entity "([^"]*)" has external reference "([^"]*)" like "([^"]*)"$/ do |entity_name, name, value|
  entity = Entity.find_by_name entity_name
  entity.external_references[name] = value
  entity.save
end

Given /^the entity "([^"]*)" has dataset value "([^"]*)" for "([^"]*)"$/ do |entity, value, field|
  entity = Entity.find_by_name(entity)
  entity.dataset[field] = value
  entity.save
end

Then /^entity "([^"]*)" should have external_reference value "([^"]*)" for "([^"]*)"$/ do |entity, value, name|
  entity = Entity.find_by_name entity
  entity.external_references[name].should == value
end

Then /^entity "([^"]*)" should have dataset value "([^"]*)" for "([^"]*)"$/ do |entity, value, name|
  entity = Entity.find_by_name entity
  entity.dataset[name].should == value  
end

When /^the "([^"]*)" "([^"]*)" is updated behind the scenes$/ do |klass, name|
  klass.classify.constantize.find_by_name(name.split('/').first).save
end

Given /^user "([^"]*)" is allowed to "([^"]*)" collection "([^"]*)" (?:through|via) credential "([^"]*)"$/ do |user, policy, collection, credential|
  step "the user \"#{user}\""
  step "the collection \"#{collection}\""
  step "the credential \"#{credential}\""
  
  user = User.find_by_name(user)
  collection = Collection.find_by_name(collection)
  credential = Credential.find_by_name(credential)

  user.groups << credential unless user.groups.include? credential
  
  policy.split("/").each do |p|
    collection.grant p, :to => credential
  end
end

Given /^the following access rights$/ do |table|
  table.hashes.each do |access|
    step "the collection \"#{access[:collection]}\""
    collection = Collection.find_by_name(access[:collection])
    step "the credential \"#{access[:credential]}\""
    credential = Credential.find_by_name(access[:credential])
    step "the user \"#{access[:user]}\""
    user = User.find_by_name(access[:user])
    
    user.groups << credential
    user.save
  
    access[:rights].chars.to_a.each do |right|
      policy = case right
        when 'r' then :admin_rating
        when 'v' then :view
        when 'e' then :edit
        when 'c' then :create
        when 'd' then :delete
        when 'l' then :download_originals
      end
      Grant.create :collection => collection, :policy => policy, :credential => credential
    end
  end
end

Given /^user "([^"]*)" is a "([^"]*)"$/ do |user, role|
  User.find_by_name(user).update_attributes role.to_sym => true
end

Then /^user "([^"]*)" should be in groups "([^"]*)"$/ do |user, groups|
  user_groups = User.find_by_name(user).groups.map{|g| g.name}
  groups = groups.split('/')
  (user_groups & groups).size.should == groups.size
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


# Attributes

Given /^the entity "([^"]*)" has the synonyms "([^"]*)"$/ do |entity, synonyms|
  Entity.find_by_name(entity).update_attributes :synonyms => synonyms.split('/')
end

Given /^the entity "([^"]*)" has the tags "([^"]*)"$/ do |entity, tag_list|
  Entity.find_by_name(entity).update_attributes :tag_list => tag_list
end


# Groups

Given /^there are some authority groups within categories$/ do
  category_1 = AuthorityGroupCategory.make(:name => "Category 1")
  category_2 = AuthorityGroupCategory.make(:name => "Category 2")
  
  category_2.authority_groups.make(:name => 'Group 1')
end

Given /^there is one global group in the database$/ do
  AuthorityGroup.create(:name => 'test_group')
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

Given /^the first medium is inside user group "([^"]*)"$/ do |name|
  step "the medium \"spec/fixtures/image_a.jpg\""
  step "the user group \"#{name}\""
  
  UserGroup.find_by_name(name).add_entities Entity.last
end

Given /^the authority group category "([^"]*)"$/ do |name|
  AuthorityGroupCategory.create :name => name
end

Given /^the authority group categories structure "([^"]*)"$/ do |structure|
  category_names = structure.split(' >> ')
  
  previous = AuthorityGroupCategory.create :name => category_names.shift
  while current = category_names.shift
    previous = AuthorityGroupCategory.create(:name => current, :parent => previous)
  end
end

Given /^the user group "([^\"]*)"( published as "[^\"]*")?$/ do |name, pub|
  unless UserGroup.find_by_name(name)
    step "I am on the user groups page"
    step "I follow \"Plus\""
    step "I fill in \"user_group[name]\" with \"#{name}\""
    step "I press \"Erstellen\""
    
    unless pub.blank?
      pub_name = pub.gsub(/.*\"([^\"]+)\".*/, "\\1")
    
      step "I go to the publishments page"
      step "I follow \"Plus\""
      step "I fill in \"publishment[name]\" with \"#{pub_name}\""
      step "I select \"#{name}\" from \"publishment[user_group_id]\""
      step "I press \"Erstellen\""
    end
  end
end

Then /^there should be only one empty authority group category$/ do
  AuthorityGroup.count.should eql(0)
  AuthorityGroupCategory.count.should eql(1)
  AuthorityGroupCategory.first.authority_groups.count.should eql(0)
end

Given /^a few authority group categories$/ do
  AGC = AuthorityGroupCategory
  
  a = AGC.make(:A)
  b = AGC.make(:B)
  c = AGC.make(:C)
  
  ba = AGC.make(:BA)
  bb = AGC.make(:BB)
  
  baa = AGC.make(:BAA)
  bab = AGC.make(:BAB)
  
  baa.move_to_child_of(ba)
  bab.move_to_child_of(ba)
  
  ba.move_to_child_of(b)
  bb.move_to_child_of(b)
end


# Assertions

Then /^there should be ([0-9]+) authority group categories$/ do |num|
  AuthorityGroupCategory.count.should eql(num.to_i)
end

Then /^there should be "([^"]*)" "([^"]*)" entity in the database$/ do |num, kind|
  Kind.find_by_name(kind).entities.count.should eql(num.to_i)
end

Then /^there should( not)? be the collection named "([^\"]*)" in the database$/ do |reverse, name|
  if reverse == ' not'
    Collection.find_by_name(name).should be_nil
  else
    Collection.find_by_name(name).should_not be_nil
  end
end

Then /^there should be no "([^"]*)" named "([^"]*)"$/ do |model, name|
  model.classify.constantize.find_by_name(name).should be_nil
end



# Combinations

Given /^the relation "([^"]*)" between "([^"]*)" and "([^"]*)"$/ do |relation, from_kind, to_kind|
  step "the kind \"#{from_kind}\""
  step "the kind \"#{to_kind}\""

  step "the relation \"#{relation}\""
  
  from_kind = Kind.find_by_name(from_kind.split('/').first)
  to_kind = Kind.find_by_name(to_kind.split('/').first)
  relation = Relation.find_by_name(relation.split('/').first)
  relation.from_kind_ids << from_kind.id
  relation.to_kind_ids << to_kind.id
  relation.save
end

Given /^the triple "([^\"]*)" "([^\"]*)" "([^\"]*)" "([^\"]*)" "([^\"]*)"$/ do |from_kind, from_name, relation, to_kind, to_name|
  step "the relation \"#{relation}\""
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

  expect(normal || reverse).to be_true
end

Given /^the relationship "([^\"]*)" "([^\"]*)" "([^\"]*)"$/ do |from, name, to|
  from = Entity.find_by_name(from)
  to = Entity.find_by_name(to)
  
  step "the relation \"#{name}\" between \"#{from.kind.name}/#{from.kind.plural_name}\" and \"#{to.kind.name}/#{to.kind.plural_name}\""

  name = name.split("/").first
  
  Relationship.relate_and_save(from, name, to)
end

Given /^the relationship "(.*?)" "(.*?)" the last medium$/ do |from, name|
  from = Entity.find_by_name(from)
  to = Medium.last.entity
  
  step "the relation \"#{name}\" between \"#{from.kind.name}/#{from.kind.plural_name}\" and \"#{to.kind.name}/#{to.kind.plural_name}\""
  
  name = name.split("/").first
  
  Relationship.relate_and_save(from, name, to)
end


# Setups

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
  step "the relation \"wird dargestellt von/stellt dar\""
  step "the medium \"spec/fixtures/image_a.jpg\""
  step "the entity \"Mona Lisa\" of kind \"Werk/Werke\""
  
  medium = Kind.medium_kind.entities.first
  mona_lisa = Entity.find_by_name('Mona Lisa')

  Relationship.relate_once_and_save(mona_lisa, "wird dargestellt von", medium)
end

Given /^Leonardo, Mona Lisa and a medium as correctly related entities$/ do
  step "Mona Lisa and a medium as correctly related entities"
  step "the relation \"hat erschaffen/wurde erschaffen von\""
  step "the entity \"Leonardo da Vinci\" of kind \"Person/Personen\""

  leonardo = Entity.find_by_name('Leonardo da Vinci')
  mona_lisa = Entity.find_by_name('Mona Lisa')

  Relationship.relate_once_and_save(leonardo, "hat erschaffen", mona_lisa)
end

Given /^there are a person and an artwork in the database$/ do
  @leonardo = Kind.find_by_name('Person').entities.create(:name => 'Leonardo da Vinci')
  @mona_lisa = Kind.find_by_name('Werk').entities.create(:name => 'Mona Lisa', :dataset => Artwork.new)
end

Given /^the entity "([^\"]*)" has ([0-9]+) relationships$/ do |name, amount|
  step "the relation \"ist äquivalent zu/ist äquivalent zu\""
  entity = Entity.find_by_name(name)
  step "the entity \"Test Entity\" of kind \"#{entity.kind.name}/#{entity.kind.plural_name}\""
  test_entity = Entity.find_by_name("Test Entity")

  amount.to_i.times do
    Relationship.relate_and_save(entity, "ist äquivalent zu", test_entity, ['Zusatzinformation'])
  end
  
  Relationship.last.update_attributes :properties => ['ENDE']
end

Given(/^the meta entities sample configuration$/) do
  Kor.config.update(YAML.load_file "#{Rails.root}/spec/fixtures/meta_entities_config.yml")
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
    expect(user.active).to be_false
  else
    expect(user.active).to be_true
  end
end

Then(/^user "(.*?)" should (not )?have the role "(.*?)"$/) do |email, n, role|
  user = User.where(:email => email).first
  if n == "not "
    expect(user.send role.to_sym).to be_false
  else
    expect(user.send role.to_sym).to be_true
  end
end

Then(/^user "(.*?)" should expire at "(.*?)"$/) do |email, time_str|
  user = User.where(:email => email).first
  time = eval(time_str)
  expect(user.expires_at).to be_within(1.minute).of(time)
end

Then(/^user "(.*?)" should not expire$/) do |email|
  expect(User.where(:email => email).first.expires_at).to be_nil
end

