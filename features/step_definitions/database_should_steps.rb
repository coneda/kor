Then /^user "([^\"]*)" should have the following access rights$/ do |user, table|
  user = User.find_by_name(user)
  
  results = []
  
  user.groups.each do |group|
    group.grants.each do |grant|
      results << {
        'collection' => grant.collection.name,
        'credential' => group.name,
        'policy' => grant.policy
      }
    end
  end
  
  if results.size == 0
    expect(table.hashes.size).to eq(0)
  else
    table.diff! results
  end
end

Then(/^kind "([^"]*)" should( not)? have parent "([^"]*)"$/) do |child, negation, parent|
  child = Kind.find_by(name: child)
  parent = Kind.find_by(name: parent)

  if negation
    expect(child.parents.to_a).not_to include(parent)
  else
    expect(child.parents.to_a).to include(parent)
  end
end

Then(/^relation "([^"]*)" should( not)? have parent "([^"]*)"$/) do |child, negation, parent|
  child = Relation.find_by(name: child)
  parent = Relation.find_by(name: parent)

  if negation
    expect(child.parents.to_a).not_to include(parent)
  else
    expect(child.parents.to_a).to include(parent)
  end
end

pattern = /^kind "([^"]*)" should( not)? have field "([^"]*)"(?: with attribute "([^"]*)" being "([^"]*)")?$/
Then(pattern) do |kind, negation, field, attr, value|
  kind = Kind.find_by(name: kind)

  if negation
    expect(kind.fields.map{|f| f.name}).not_to include(field)
  else
    expect(kind.fields.map{|f| f.name}).to include(field)
    if attr.present?
      expect(kind.fields.find_by(name: field).send(attr)).to eq(value)
    end
  end
end

pattern = /^kind "([^"]*)" should( not)? have generator "([^"]*)"$/
Then(pattern) do |kind, negation, generator|
  kind = Kind.find_by(name: kind)

  if negation
    expect(kind.generators.map{|f| f.name}).not_to include(generator)
  else
    expect(kind.generators.map{|f| f.name}).to include(generator)
  end
end

Then(/^there should only be one relation "([^"]*)"$/) do |name|
  name, reverse_name = name.split(/\s*\/\s*/)
  expect(Relation.where(name: name, reverse_name: reverse_name).count).to eq(1)
end