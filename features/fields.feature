Feature: Fields
  Scenario: enter data in a field
    Given I am logged in as "admin"
    And I select "person" from "new_entity_type"
    And I fill in "Name" with "Van Gogh"
    And I fill in "GND-ID" with "667788"
    And I press "Save"
    Then I should be on the entity page for "Van Gogh"
    And I should see "GND-ID: 667788"