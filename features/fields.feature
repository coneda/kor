Feature: Fields
  In order to handle dynamic datasets
  As a admin
  I want to be able to add fields to kinds
  
  
  @javascript
  Scenario: Create a field and then an entity
    Given I am logged in as "admin"
    And the kind "Werk/Werke"
    When I go to the kinds page
    And I follow "Three_bars" within the row for "kind" "Werk"
    And I follow "Plus"
    And I fill in "field[name]" with "material"
    And I fill in "field[show_label]" with "Material"
    And I check "field[show_on_entity]"
    And I press "Erstellen"
    Then I should not see "Fehler" within ".canvas"
    
    When I go to the new "Werk-Entity" page
    And I fill in the following:
      | entity[name] | Mona Lisa |
      | entity[dataset][material] | Öl auf Leinwand |
    And I press "Erstellen"
    Then I should be on the entity page for "Mona Lisa"
    And I should see "Material"
    And I should see "Öl auf Leinwand"
    
    
  Scenario: Update a field
    Given I am logged in as "admin"
    And kind "Werk/Werke" has field "material" of type "Fields::String"
    When I go to the kinds page
    And I follow "Three_bars" within the row for "kind" "Werk"
    And I follow "Pen" within the row for "field" "material"
    And I fill in "field[form_label]" with "Material & Technik"
    And I press "Speichern"
    And I go to the new "Werk-Entity" page
    Then I should see "Material & Technik"
    
    
  Scenario: Enter a regex with dangerous code
    Given I am logged in as "admin"
    And kind "Werk/Werke" has field "material" of type "Fields::Regex"
    When I go to the kinds page
    And I follow "Three_bars" within the row for "kind" "Werk"
    And I follow "Pen" within the row for "field" "material"
    And I fill in "field[settings][regex]" with harmful code
    And I press "Speichern"
    And I go to the new "Werk-Entity" page
    And I fill in "entity[name]" with "Mona Lisa"
    And I fill in "entity[dataset][material]" with "Öl auf Leinwand"
    And I press "Erstellen"
    Then the harmful code should not have been executed
    
