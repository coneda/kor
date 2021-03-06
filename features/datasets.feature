Feature: Datasets
  Scenario: Show the form for an entity with a customized dataset
    Given I am logged in as "admin"
    When I go to the new "Person-Entity" page
    Then I should see field "GND-ID"
    Then I should see field "Wikidata ID"
    
  Scenario: Create an entity with a customized dataset
    Given I am logged in as "admin"
    When I go to the new "Person-Entity" page
    And I fill in "Name" with "Van Gogh"
    And I fill in "GND-ID" with "6789"
    And I fill in "Wikidata ID" with "1223"
    And I press "Save"
    Then I should see "has been created"
    Then I should be on the entity page for "Van Gogh"
    And I should see "GND-ID: 6789"
    And I should not see "Wikidata ID: 1223"

  Scenario: Create en entity with a multi-line field
    Given I am logged in as "admin"
    And I select "work" from "new_entity_type"
    Then field "Description" should be a textarea
    
  Scenario: Try to create an invalid entity with a customized dataset which has to be validated
    Given I am logged in as "admin"
    And kind "Literatur/Literatur" has field "isbn" of type "Fields::Isbn"
    When I go to the new "Literatur-Entity" page
    And I fill in "Name" with "Fräulein Smillas Gespür für Schnee"
    And I fill in "Isbn" with "wrong isbn format"
    And I press "Save"
    Then I should see "the input contains errors"
    And I should see error "is invalid" on field "Isbn"
    
  Scenario: Try to create an valid entity with a customized dataset which has to be validated
    Given I am logged in as "admin"
    And kind "Literatur/Literatur" has field "isbn" of type "Fields::Isbn"
    When I go to the new "Literatur-Entity" page
    And I fill in "Name" with "Fräulein Smillas Gespür für Schnee"
    And I fill in "Isbn" with "3499237016"
    And I press "Save"
    Then I should see "has been created"
    Then I should be on the entity page for "Fräulein Smillas Gespür für Schnee"
    Then I should not see "Translation missing"
    And I should see "3499237016"

  Scenario: Add a mandatory select field and create an entity
    Given I am logged in as "admin"
    And kind "Person/Personen" has field "cycle" of type "Fields::Select"
    And field "cycle" is mandatory
    And select field "cycle" allows the values "sun, moon"
    When I go to the new "Person-Entity" page
    Then I should see field "Cycle" with value ""
    When I press "Save"
    Then I should see error "has to be filled in" on field "Cycle"
    When I select "sun" from "Cycle"
    And I press "Save"
    Then I should not see error "has to be filled in" on field "Cycle"
    Then I should not see error "has to be filled in" on field "Cycle"

  Scenario: Mandatory field on medium when uploading
    Given I am logged in as "admin"
    And kind "Medium/Media" has field "cycle" of type "Fields::Select"
    And field "cycle" is mandatory
    When I follow "Upload"
    Then I should see field "Cycle"
    