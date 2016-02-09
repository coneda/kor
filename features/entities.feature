Feature: Entities
  In order to manage diverse information
  As a user
  I should be able to manage entities
  
  
  Scenario: Invalid entities
    Given I am logged in as "admin"
    And 40 invalid entities "Mona Lisa" of kind "Werk" inside collection "default"
    And I follow "Invalid entities"
    Then I should see "go to page"
  

  Scenario: Search fields
    Given I am logged in as "admin"
    When I go to the expert search
    Then I should see "Dating"


  @javascript
  Scenario: Show an entity with 12 relationships of the same kind
    Given I am logged in as "admin"
    And the entity "Nürnberg" of kind "Ort/Orte"
    And the entity "Nürnberg" has 12 relationships
    When I go to the entity page for "Nürnberg"
    Then I should see element ".pagination input"
    When I click element "img[alt='Pager_right']" within ".relation"
    And I follow "Triangle_up" within ".relation"
    Then I should see /ENDE/ within ".relationships"


  @javascript
  Scenario: Upload a medium
    Given I am logged in as "admin"
    When I go to the legacy upload page
    Then I should see "Create medium"
    When I attach the file "spec/fixtures/image_a.jpg" to "entity[medium_attributes][document]"
    And I press "Create"
    Then there should be "1" "Medium" entity in the database
    And I should be on the entity page for the last medium
    And I should see "Medium"
    

  @javascript
  Scenario: Create an entity as an unauthorized user
    Given I am logged in as "john"
    And the kind "Werk/Werke"
    When I go to the new "Werk-Entity" page
    Then I should be on the denied page
    
  
  @javascript
  Scenario: Create entities with a date, specific information and some synonyms and remove some later
    Given I am logged in as "admin"
    And the kind "Werk/Werke"
    When I go to the root page
    And I select "Werk" from "new_entity[kind_id]"
    And I fill in "entity[name]" with "Mona Lisa"
    
    And I follow "Plus" within "#datings"
    And I fill in "datings" attachment "1" with "/1688"
    And I follow "Plus" within "#properties"
    And I fill in "properties" attachment "1" with "Alter/12"
    And I follow "Plus" within "#synonyms"
    And I fill in "synonyms" attachment "1" with "La Bella"
    And I follow "Plus" within "#synonyms"
    And I fill in "synonyms" attachment "2" with "La Gioconde"
    
    And I press "Create"
    Then I should be on the entity page for "Mona Lisa"
    And I should see "1688"
    And I should see "Alter"
    And I should see "12"
    And I should see "La Bella"
    And I should see "La Gioconde"
    
    When I follow "Pen"
    And I follow "Minus" within "#synonyms .attachment:first-child"
    And I press "Save"
    Then I should be on the entity page for "Mona Lisa"
    And I should see "1688"
    And I should see "Alter"
    And I should see "12"
    And I should not see "La Bella"
    And I should see "La Gioconde"
    
  
  Scenario: I don't see the select as current link when I have no edit rights for no collection
    Given I am logged in as "john"
    And the entity "Mona Lisa" of kind "Werk/Werke"
    When I go to the entity page for "Mona Lisa"
    Then I should not see element "img[alt=Select]"
    
    
  @javascript  
  Scenario: I see the select link when I have edit rights for any collection
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "Werk/Werke"
    And user "john" is allowed to "edit" collection "Nebensammlung" through credential "Nebenuser"
    And user "john" is allowed to "view" collection "Default" through credential "Nebenuser"
    And I am logged in as "john"
    When I go to the entity page for "Mona Lisa"
    Then I should see element "a[kor-current-button]"

  
  @javascript
  Scenario: Edit an entity with only edit and view rights
    Given the entity "Mona Lisa" of kind "Werk/Werke" inside collection "Nebensammlung"
    And user "john" is allowed to "view/edit" collection "Nebensammlung" through credential "Nebenuser"
    And I am logged in as "john"
    When I go to the entity page for "Mona Lisa"
    And I follow "Pen"
    And I fill in "entity[name]" with "La Gioconde"
    And I press "Save"
    Then I should be on the entity page for "La Gioconde"
    And I should see "La Gioconde"


  Scenario: Try to create an entity with the same name twice (same collection)
    Given I am logged in as "admin"
    And the kind "Werk/Werke"
    And I go to the new "Werk-Entity" page
    And I fill in "entity[name]" with "Mona Lisa"
    And I press "Create"
    When I go to the new "Werk-Entity" page
    And I fill in "entity[name]" with "Mona Lisa"
    And I press "Create"
    Then I should see "name is already taken"
    
  
  Scenario: Try to create an entity with the same name twice (different collections)
    Given the kind "Werk/Werke"
    And the collection "side"
    And user "admin" is allowed to "view/edit/create" collection "side" through credential "can_do_it"
    And I am logged in as "admin"
    And I go to the new "Werk-Entity" page
    And I fill in "entity[name]" with "Mona Lisa"
    And I press "Create"
    When I go to the new "Werk-Entity" page
    And I select "side" from "entity[collection_id]"
    And I fill in "entity[name]" with "Mona Lisa"
    And I press "Create"
    Then I should see "name is already taken"
  
 
  Scenario: Try to create an entity with the same name within another collection
    Given the entity "Mona Lisa" of kind "Werk/Werke"
    And user "john" is allowed to "view/create" collection "Nebensammlung" through credential "Nebenuser"
    And I am logged in as "john"
    When I go to the new "Werk-Entity" page
    And I fill in "entity[name]" with "Mona Lisa"
    And I press "Create"
    Then I should see "conflict with collection 'Default'"
    
  
  @javascript
  Scenario: When paginating relationships, images should have a button bar
    Given I am logged in as "admin"
    And the setup "Many relationships with images"
    When I go to the entity page for "Mona Lisa"
    And I wait for "1" second
    When I click element "img[alt='Pager_right']" within ".relation"
    And I follow "Triangle_up" within ".relationship"
    And I wait for "1" seconds
    And I hover element ".relationships .kor_medium_frame"
    And I click on ".kor_medium_frame .button_bar a[kor-to-clipboard]"
    Then I should see "has been copied to the clipboard"


  @javascript
  Scenario: Don't show relationships to unauthorized entities
    Given the collection "side"
    And the relation "has created/has been created by"
    And the entity "Leonardo da Vinci" of kind "Person/People" inside collection "default"
    And the entity "Mona Lisa" of kind "Work/Works" inside collection "side"
    And the relationship "Leonardo da Vinci" "has created" "Mona Lisa"
    Given I am logged in as "admin"
    When I go to the entity page for "Leonardo da Vinci"
    Then I should not see "Mona Lisa"

    Given user "admin" is allowed to "view" collection "side" through credential "side_admins"
    When I go to the entity page for "Leonardo da Vinci"
    Then I should see "Mona Lisa"


  @javascript
  Scenario: Don't show edit or delete buttons for unauthorized relationships
    Given the collection "side"
    And the relation "has created/has been created by"
    And the entity "Leonardo da Vinci" of kind "Person/People" inside collection "default"
    And the entity "Mona Lisa" of kind "Work/Works" inside collection "side"
    And the relationship "Leonardo da Vinci" "has created" "Mona Lisa"
    Given user "admin" is allowed to "view" collection "side" through credential "side_admins"

    Given I am logged in as "admin"
    When I go to the entity page for "Leonardo da Vinci"
    Then I should see "Mona Lisa"
    And I should not see element "img[title=Pen]" within ".relationship"


  @javascript @nodelay
  Scenario: Click the big image on media to return to the entity screen
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    When I go to the last entity's page
    And I follow "Image" within ".viewer"
    And I follow "Image" within ".image_projector"
    Then I should be on the last entity's page


  @javascript
  Scenario: It should expand all relationships for a relation in one go
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "Work/Works"
    And the entity "Das letzte Abendmahl" of kind "Work/Works"
    And the entity "Leonardo" of kind "Person/People"
    And the medium "spec/fixtures/image_a.jpg"
    And the relation "has created/was created by"
    And the relation "shows/is depicted by"
    And the relationship "Leonardo" "has created" "Mona Lisa"
    And the relationship "Leonardo" "has created" "Das letzte Abendmahl"
    And the relationship "Mona Lisa" "is depicted by" the last medium
    And the relationship "Das letzte Abendmahl" "is depicted by" the last medium
    When I go to the entity page for "Leonardo"
    And I click on the upper triangle for relation "has created"
    Then I should see "2" kor images within the first relation on the page
