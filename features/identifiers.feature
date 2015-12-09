Feature: Identifiers

@javascript
Scenario: Create a resolvable entity and resolve it
  Given I am logged in as "admin"
  And the kind "Person/People"
  And I go to the kinds page
  And I follow "Three_bars" within the row for "kind" "Person"
  And I follow "Plus"
  And I fill in "field[name]" with "gnd_id"
  And I fill in "field[show_label]" with "GND-ID"
  And I check "field[is_identifier]"
  And I press "Erstellen"
  And I go to the new "Person-Entity" page
  And I fill in "entity[name]" with "Leonardo da Vinci"
  And I fill in "entity[dataset][gnd_id]" with "1234"
  And I press "Erstellen"
  And I go to the path "/resolve/gnd_id/1234"
  Then I should be on the entity page for "Leonardo da Vinci"
  And I go to the path "/resolve/1234"
  Then I should be on the entity page for "Leonardo da Vinci"