When /^I edit entity "([^\"]*)"$/ do |name|
  visit edit_entity_path(Entity.find_by_name(name))
end
