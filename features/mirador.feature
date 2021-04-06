Feature: mirador v2 integration

Scenario: use User's locale setting
  Given I am logged in as "admin"
  When I go to the mirador page
  Then I should see "Full Screen"
  Given user "admin" has locale "de"
  And I reload the page
  Then I should see "Vollbild"

Scenario: default manifests
  Given I am logged in as "admin"
  When I go to the mirador page
  And I click element "a.addItemLink"
  Then I should see "National Gallery of Art"

Scenario: alternate launch page
  Given the setting "mirador_page_template" is "spec/fixtures/mirador.page.html"
  And I am logged in as "admin"
  When I go to the mirador page
  Then I should see page title "An alternative mirador integration page"

# http://localhost:3000/mirador?manifest=http://localhost:3000/mirador/13629