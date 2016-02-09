Feature: Datasets
  As a user
  In order to attach variable data to entities
  I want to be able to attach customizable datasets to entities
  
  
  Scenario: Show the form for an entity with a customized dataset
    Given I am logged in as "admin"
    And kind "Werk/Werke" has field "material" of type "Fields::String"
    When I go to the new "Werk-Entity" page
    Then I should see "Material"
    And I should see element "input[name='entity[dataset][material]']"
    
    
  @javascript
  Scenario: Create an entity with a customized dataset
    Given I am logged in as "admin"
    And kind "Werk/Werke" has field "material" of type "Fields::String"
    When I go to the new "Werk-Entity" page
    And I fill in "entity[name]" with "Mona Lisa"
    And I fill in "entity[dataset][material]" with "Öl auf Leinwand"
    And I press "Create"
    Then I should be on the entity page for "Mona Lisa"
    And I should see "Material"
    And I should see "Öl auf Leinwand"
    
    
  Scenario: Try to create an invalid entity with a customized dataset which has to be validated
    Given I am logged in as "admin"
    And kind "Literatur/Literaturen" has field "isbn" of type "Fields::Isbn"
    When I go to the new "Literatur-Entity" page
    And I fill in "entity[name]" with "Fräulein Smillas Gespür für Schnee"
    And I fill in "entity[dataset][isbn]" with "wrong isbn format"
    And I press "Create"
    Then I should not see "Translation missing"
    Then I should see "Isbn is invalid"
    
  
  @javascript
  Scenario: Try to create an valid entity with a customized dataset which has to be validated
    Given I am logged in as "admin"
    And kind "Literatur/Literaturen" has field "isbn" of type "Fields::Isbn"
    When I go to the new "Literatur-Entity" page
    And I fill in "entity[name]" with "Fräulein Smillas Gespür für Schnee"
    And I fill in "entity[dataset][isbn]" with "3499237016"
    And I press "Create"
    Then I should be on the entity page for "Fräulein Smillas Gespür für Schnee"
    Then I should not see "Translation missing"
    And I should see "3499237016"
