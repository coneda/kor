Feature: Fields
  Scenario: enter data in a field
    Given I am logged in as "admin"
    And I select "person" from "new_entity_type"
    Then I should see "Create person"
    And I fill in "Name" with "Van Gogh"
    And I fill in "GND-ID" with "667788"
    And I press "Save"
    Then I should see "has been created"
    And I should be on the entity page for "Van Gogh"
    And I should see "GND-ID: 667788"

  Scenario: create a regex field and use it

  Scenario: create select field and use it
    Given I am logged in as "admin"
    And I follow "Entity types"
    And I follow "person"
    And I follow "add" within widget "kor-fields"
    And I select "select" from "Type"
    And I fill in "Name" with "profession"
    And I fill in "Label" with "profession"
    And I select "select" from "Subtype"
    And I fill in value list with "carpenter|weaver|stone mason"
    And I check "Visible on entity page"
    And I press "Save"
    Then I should see "profession has been created"
    When I follow "profession" within widget "kor-fields"
    Then the select "Subtype" should have value "select"
    And value list should have value "carpenter|weaver|stone mason"

    When I go to the entity page for "Leonardo"
    And I follow "edit"
    And I select "stone mason" from "profession"
    And I press "Save"
    Then entity "Leonardo" should have dataset value "stone mason" for "profession"

    When I follow "Entity types"
    And I follow "person"
    And I follow "profession" within widget "kor-fields"
    And select "multiselect" from "Subtype"
    And I press "Save"

    When I go to the entity page for "Leonardo"
    And I follow "edit"
    And I select "stone mason" from "profession"
    And I select "carpenter" from "profession"
    And I press "Save"
    Then I should see "Leonardo has been changed"
    And I should see "profession: carpenter, stone mason"




