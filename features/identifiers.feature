Feature: Identifiers

@javascript @nodelay
Scenario: Create a resolvable entity and resolve it
  Given I am logged in as "admin"
  And the kind "person/people"
  And the kind "person" has identifier "gnd_id" labelled "GND-ID"
  And I go to the new "Person-Entity" page
  And I fill in "entity[name]" with "Leonardo da Vinci"
  And I fill in "entity[dataset][gnd_id]" with "1234"
  And I press "Create"
  And I go to the path "/resolve/gnd_id/1234"
  Then I should be on the entity page for "Leonardo da Vinci"
  And I go to the path "/resolve/1234"
  Then I should be on the entity page for "Leonardo da Vinci"