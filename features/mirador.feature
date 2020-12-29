Feature: mirador v2 integration

Scenario: default locale
  Given I am logged in as "admin"
  When I go to the mirador page
  Then I should see "Full Screen"
  Given user "admin" has locale "de"
  And I reload the page
  Then I should see "Vollbild"

# http://localhost:3000/mirador?manifest=http://localhost:3000/mirador/13629