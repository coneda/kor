Feature: Entity authentorization
  In order to secure my entities against unauthorized access
  As an admin
  I want to work with a fine grained permission system
  
  
  Background:
    Given I am logged in as "joe"

  
  @javascript
  Scenario: Show the select as current link for viewable entities because he has edit rights in another collection
    Given user "joe" is allowed to "view/edit" collection "side" through credential "side_editors"
    And user "joe" is allowed to "view" collection "main" through credential "main_viewers"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "main"
    When I go to the entity page for "Mona Lisa"
    Then I should see element "a[kor-to-current]"
    
  
  @javascript
  Scenario: Allow editing given appropriate authorization
    Given user "joe" is allowed to "view/edit" collection "side" through credential "side_editors"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "side"
    When I go to the entity page for "Mona Lisa"
    Then I should see element "img[data-name=pen]"
    
  
  @javascript
  Scenario: Allow deleting entities given appropriate authorization
    Given user "joe" is allowed to "view/delete" collection "side" through credential "side_editors"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "side"
    When I go to the entity page for "Mona Lisa"
    Then I should see element "img[data-name=x]"
  
  
  @javascript
  Scenario: Don't show relationships to unauthorized entities
    Given user "joe" is allowed to "view" collection "main" through credential "main_viewers"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "main"
    And the entity "Leonardo da Vinci" of kind "Person/People" inside collection "side"
    And the relationship "Mona Lisa" "wurde geschaffen von/hat geschaffen" "Leonardo da Vinci"
    When I go to the entity page for "Mona Lisa"
    Then I should not see "wurde geschaffen von"
    
    
  @javascript
  Scenario: Show the 'add relationship' when the user is allowed to edit any collection
    Given user "joe" is allowed to "view" collection "main" through credential "main_viewers"
    And user "joe" is allowed to "edit" collection "side" through credential "side_editors"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "main"
    When I go to the entity page for "Mona Lisa"
    Then I should see element "img[data-name=plus]" within ".relationships"
    
    
  @javascript
  Scenario: Show edit and delete buttons for authorized relationships
    Given user "joe" is allowed to "view" collection "main" through credential "main_viewers"
    And user "joe" is allowed to "view/edit" collection "side" through credential "main_viewers"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "main"
    And the entity "Leonardo da Vinci" of kind "Person/People" inside collection "side"
    And the relationship "Mona Lisa" "wurde geschaffen von/hat geschaffen" "Leonardo da Vinci"
    When I go to the entity page for "Mona Lisa"
    Then I should see element "img[data-name=pen]" within ".relationships"
    Then I should see element "img[data-name=x]" within ".relationships"
    When I go to the entity page for "Leonardo da Vinci"
    Then I should see element "img[data-name=pen]" within ".relationships"
    Then I should see element "img[data-name=x]" within ".relationships"
    
    
  @javascript
  Scenario: Show media previews for authorized media entities
    Given user "joe" is allowed to "view" collection "main" through credential "main_viewers"
    And user "joe" is allowed to "view" collection "side" through credential "main_viewers"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "main"
    And the medium "spec/fixtures/image_a.jpg" inside collection "side"
    And the relationship "Mona Lisa" "wird dargestellt durch/stellt dar" the last medium
    When I go to the entity page for "Mona Lisa"
    Then I should see element ".kor_medium_frame" within ".layout_panel.right .related_images"
  
  
  @javascript
  Scenario: Don't allow editing without appropriate authorization
    Given user "joe" is allowed to "view/edit" collection "main" through credential "main_viewers"
    And user "joe" is allowed to "view" collection "side" through credential "main_viewers"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "side"
    When I go to the entity page for "Mona Lisa"
    Then I should not see element "img[data-name=pen]"
  

  @javascript
  Scenario: I should not see meta data for collections that don't allow me to
    Given user "joe" is allowed to "view" collection "main" through credential "main_viewers"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "main"
    When I go to the entity page for "Mona Lisa"
    Then I should not see element "div" with text "Stammdaten"

  @javascript
  Scenario: I should see meta data for collections that allow me to
    Given user "joe" is allowed to "view/view_meta" collection "main" through credential "main_viewers"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "main"
    When I go to the entity page for "Mona Lisa"
    Then I should see element ".processing_data" with text "Master data"
