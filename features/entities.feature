Feature: Entities
  Scenario: Invalid entities
    Given I am logged in as "admin"
    And 40 invalid entities "Mona Lisa" of kind "Werk" inside collection "default"
    And I follow "Invalid entities"
    Then I should see "of 2" within ".w-content"
  
  Scenario: Search fields
    Given I am logged in as "admin"
    When I go to the search page
    Then I should see "Dating"

  Scenario: Create an entity as an unauthorized user
    Given I am logged in as "jdoe"
    When I go to the new "work-Entity" page
    Then I should see "Access denied"
  
  Scenario: Create entities with a date, specific information and some synonyms and remove some later
    Given I am logged in as "admin"
    When I go to the root page
    And I select "work" from "new_entity_type"
    And I fill in "Name" with "Der Schrei"

    And I press "Add" within widget "kor-datings-editor"
    And I fill in "Dating" with "1688"
    And I fill in "Further properties" with "Alter: 12"
    And I fill in synonyms with "La Bella|La Gioconde"
    
    And I press "Save"
    Then I should see "has been created"
    And I should be on the entity page for "Der Schrei"
    And I should see "dating: 1688"
    And I should see "Alter: 12"
    And I should see "Synonyms: La Bella | La Gioconde"
    
    When I follow "edit"
    Then field "Synonyms" should contain "La Bella"
    Then field "Synonyms" should contain "La Gioconde"
    And I fill in synonyms with "La Gioconde"
    And I press "Save"
    Then I should see "has been changed"
    Then I should be on the entity page for "Der Schrei"
    And I should see "dating: 1688"
    And I should see "Alter: 12"
    And I should see "Synonyms: La Gioconde"

  Scenario: I don't see the select as current link when I have no edit rights for no collection
    Given the entity "Mona Lisa" of kind "Werk/Werke"
    And user "john" is allowed to "view" collection "default" via credential "users"
    And I am logged in as "john"
    When I go to the entity page for "Mona Lisa"
    And I should see "Mona Lisa"
    Then I should not see element "a[kor-current-button]"
    
  Scenario: I see the add to clipboard link
    And I am logged in as "jdoe"
    When I go to the entity page for "Mona Lisa"
    Then I should see element "a.to-clipboard"
  
  Scenario: Edit an entity with only edit and view rights
    And user "jdoe" is allowed to "edit" collection "default" through credential "students"
    And I am logged in as "jdoe"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I follow "edit"
    And I fill in "Name" with "La Gioconde"
    And I press "Save"
    Then I should see "has been changed"
    Then I should be on the entity page for "La Gioconde"
    And I should see "La Gioconde"

  Scenario: Try to create an entity with the same name twice (same collection)
    Given I am logged in as "admin"
    And I go to the new "location-Entity" page
    And I fill in "Name" with "Paris"
    And I press "Save"
    And I should see "is already taken"
    And I should see error "is invalid" on field "Distinguished name"
  
  Scenario: Try to create an entity with the same name twice (different collections)
    Given I am logged in as "admin"
    And I go to the new "location-Entity" page
    And I fill in "Name" with "Paris"
    And I press "Save"
    Then I should see "is already taken"
    And I should see error "is invalid" on field "Distinguished name"
    When I select "private" from "Collection"
    And I press "Save"
    Then I should see "is already taken"
    And I should see error "is needed for determination (conflict with collection 'Default')" on field "Distinguished name"

  Scenario: When paginating relationships, images should have a button bar
    Given I am logged in as "admin"
    And mona lisa has many relationships
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I follow "next"
    And I follow "expand" within "kor-relation[name='is related to'] kor-relationship"
    And I follow "add to clipboard" within "kor-relation[name='is related to']"
    Then I should see "has been added to the clipboard"

  Scenario: Don't show relationships to unauthorized entities
    Given I am logged in as "jdoe"
    When I go to the entity page for "Mona Lisa"
    Then I should not see "The Last Supper"
    When I follow "logout"
    And I am logged in as "admin"
    When I go to the entity page for "Mona Lisa"
    Then I should see "The Last Supper"

  Scenario: Don't show edit or delete buttons for unauthorized relationships
    Given I am logged in as "jdoe"
    When I go to the entity page for "Paris"
    Then I should not see link "edit" within "kor-relationship"
    When I follow "logout"
    Then I should see "logged out"
    And I am logged in as "admin"
    When I go to the entity page for "Paris"
    Then I should see link "edit relationship" within "kor-relationship"

  Scenario: Click the big image on media to return to the entity screen
    Given I am logged in as "admin"
    When I go to the entity page for the last medium
    And I follow "larger" within ".viewer"
    And I follow "smaller"
    Then I should be on the entity page for the last medium

  Scenario: It should expand all relationships for a relation in one go
    Given I am logged in as "admin"
    When I go to the entity page for "Leonardo"
    And I follow "expand" within "kor-relation[name='has created'] > .name"
    Then I should see "2" kor images within "kor-relation[name='has created']"

  Scenario: Display creator and updater next in the master data
    And I am logged in as "admin"
    And the entity "Mona Lisa" was created by "jdoe"
    And the entity "Mona Lisa" was updated by "admin" 
    When I go to the entity page for "Mona Lisa"
    Then I should see "by John Doe"
    And I should see "by administrator"

  Scenario: Delete an entity
    Given I am logged in as "admin"
    And I follow "Search"
    When I go to the entity page for "Mona Lisa"
    And I ignore the next confirmation box
    And I follow "delete"
    Then I should see "has been deleted"

  Scenario: Edit an entity with editing rights but without tagging rights
    Given user "jdoe" is allowed to "view/edit" collection "default" via "users"
    And I am logged in as "jdoe"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    Then I should see "Tags" within ".w-content"

  Scenario: mirador anchor value should be a real link
    Given I am logged in as "admin"
    When I go to the entity page for the last medium
    Then I should see mirador link with a usable href

  Scenario: render further properties with url-values as link
    Given I am logged in as "admin"
    And I go to the entity page for "Mona Lisa"
    And I follow "edit"
    And I fill in "Further properties" with "Wikipedia: https://en.wikipedia.org/wiki/Mona_Lisa"
    And I press "Save"
    Then I should see a link "» Wikipedia" leading to "https://en.wikipedia.org/wiki/Mona_Lisa"
