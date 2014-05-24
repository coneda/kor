When /^I fill in the meta entity$/ do |table|
  table.hashes.each do |entry|
    step "I fill in \"meta_entity[#{entry[:id]}][][name]\" with \"#{entry[:text]}\""
  end
end
