Given("the setting {string} is {string}") do |key, value|
  Kor.settings.update key => value
end

Then("the config value {string} should be {string}") do |key, value|
  Kor.settings.ensure_fresh
  expect(Kor.settings[key]).to eq(value)
end
