Feature: Kinds
  In order to have better search criteria
  Users should be able to
  apply a kind to each entity
  

  Scenario: List kinds
    Given I am logged in as "admin"
    When I go to the kinds page
    Then I should see "Entity types"


  Scenario: create kind
    Given I am logged in as "admin"
    When I go to the kinds page
    And I follow "Plus"
    And I fill in "kind[name]" with "Kind girl"
    And I fill in "kind[plural_name]" with "Kind girls"
    And I press "Create"
    Then I should see "Kind girl"


  Scenario: edit kind
    Given I am logged in as "admin"
    And the kind "Kind girl/Kind girls"
    When I go to the kinds page
    And I follow "Pen" within the row for "kind" "Kind girl"
    And I fill in "kind[name]" with "Kind boy"
    And I fill in "kind[plural_name]" with "Kind boys"
    And I press "Save"
    Then I should see "Kind boy"
    And I should not see "Kind girl" within "table.canvas"


  @javascript
  Scenario: delete kind
    Given I am logged in as "admin"
    And the kind "Kind girl/Kind girls"
    When I go to the kinds page
    When I follow the delete link within the row for "kind" "Kind girl"
    Then I should not see "Kind girl" within "table.canvas"
    

  Scenario: do not allow to destroy the medium kind
    Given I am logged in as "admin"
    When I go to the kinds page
    Then I should not see "img[data-name=x]" within "table.kor_table"
    When I send the delete request for "kind" "Medium"
    Then I should be on the denied page


  Scenario: Do not allow to rename the medium kind
    Given I am logged in as "admin"
    When I go to the kinds page
    And I follow "Pen"
    Then I should not see element "input[name='kind[name]']"
    And I should not see element "input[name='kind[plural_name]']"
    

  @javascript    
  Scenario: Create a kind and then an entity
    Given I am logged in as "admin"
    And I am on the kinds page
    
    When I follow "Plus"
    Then I should see "Create entity type"
    When I fill in "kind[name]" with "Werk"
    And I fill in "kind[plural_name]" with "Werke"
    And I press "Create"
    Then I should be on the kinds page
    And I should see "Werk"
    And I should see the option to create a new "Werk"
    
    When I go to the new "Werk-Entity" page
    Then I should see "Create Werk"
    When I fill in "entity[name]" with "Mona Lisa"
    And I press "Create"
    Then I should be on the entity page for "Mona Lisa"
    And I should see "Mona Lisa"
    
    
  @javascript
  Scenario: Create kind with dataset profile
    Given I am logged in as "admin"
    When I go to the kinds page
    And I follow "Plus"
    And I fill in "kind[name]" with "Werk"
    And I fill in "kind[plural_name]" with "Werke"
    And I press "Create"
    Then I should be on the kinds page
    And I should see "Werk"
    When I follow "Three bars" within the row for "kind" "Werk"
    And I follow "Plus"
    And I fill in "field[name]" with "material"
    And I fill in "field[show_label]" with "Material"
    And I fill in "field[form_label]" with "Material"
    And I press "Create"
    When I go to the new "Werk-Entity" page
    Then I should see "Material"
    
    
  @javascript
  Scenario: Naming should not be required for media
    Given I am logged in as "admin"
    And I go to the new "Medium-Entity" page
    Then I should not see "Name"

