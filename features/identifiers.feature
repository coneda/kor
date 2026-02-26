Feature: Identifiers
  Scenario: Create a resolvable entity and resolve it
    Given I am logged in as "admin"
    When I go to the path "/resolve/gnd_id/123456789"
    Then I should be on the entity page for "Leonardo"
    When I go to the path "/resolve/123456789"
    Then I should be on the entity page for "Leonardo"
    
  Scenario: Resolve by an identifier with a dot
    Given the entity "Leonardo" has dataset value "prefix:12345.0" for "gnd_id"
    When I go to the path "/resolve/gnd_id/prefix:12345.0"
    Then I should be on the entity page for "Leonardo"
  