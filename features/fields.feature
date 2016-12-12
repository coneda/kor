Feature: Fields
  In order to handle dynamic datasets
  As a admin
  I want to be able to add fields to kinds
  
  
  @javascript
  Scenario: Create a field and then an entity
    Given the kind "artwork/artworks"
    And kind "artwork/artworks" has field "material" of type "Fields::String"
    Given I am logged in as "admin"
    When I select "artwork" from "new_entity[kind_id]"
    And I fill in the following:
      | entity[name] | Mona Lisa |
      | entity[dataset][material] | Öl auf Leinwand |
    And I press "Create"
    Then I should be on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I should see "Material"
    And I should see "Öl auf Leinwand"
    