Feature: Cross collection relationships

  Background:
    Given the setup "Frankfurt-Berlin"

  @javascript
  Scenario Outline: cross_collection_interface
    And the user "<username>" with credential "<credential>"
    And I am logged in as "<username>"
    And the triple "Werk/Werke" "Frankfurter Dom" "Standort in/Standort von" "Ort/Orte" "Kreuzberg"
    When I go to the entity page for "Kreuzberg"
    Then I should see "<seeb>"
    And I should <seeselectb> element "img[alt=Select]" within ".metadata"
    And I should <seetargetb> element "img[alt=Target]" within ".metadata"
    And I should <seepenb> element "img[alt=Pen]" within ".metadata"
    And I should <seexb> element "img[alt=X]" within ".metadata"
    And I should <seeplusb> element "img[alt=Plus]" within ".layout_panel.left .relationships"
    And I should <seerelb> "Frankfurter Dom" within ".relationship"
    When I go to the entity page for "Frankfurter Dom"
    Then I should see "<seef>"
    And I should <seeselectf> element "img[alt=Select]" within ".metadata"
    And I should <seetargetf> element "img[alt=Target]" within ".metadata"
    And I should <seepenf> element "img[alt=Pen]" within ".metadata"
    And I should <seexf> element "img[alt=X]" within ".metadata"
    And I should <seeplusf> element "img[alt=Plus]" within ".layout_panel.left .relationships"
    And I should <seerelf> element ".relationship"
    And I should <seerelpenf> element "img[alt=Pen]" within ".relationship.stage_panel"

    Examples:
      | username | credential      | seeb       | seeselectb | seetargetb | seepenb | seexb   | seeplusb | seerelb | seef | seeselectf | seetargetf | seepenf | seexf   | seeplusf | seerelf | seerelpenf |
      | Fuser    | User Frankfurt  | Kreuzberg  | not see    | see        | not see | not see | not see  | see     | Dom  | not see    | see        | not see | not see | not see  | see     | not see    |
      | Fadmin   | Admin Frankfurt | Kreuzberg  | see        | see        | not see | not see | see      | see     | Dom  | see        | see        | see     | see     | see      | see     | see        |
      | Badmin   | Admin Berlin    | Kreuzberg  | see        | see        | see     | see     | see      | see     | Dom  | see        | see        | not see | not see | see      | see     | see        |

   
    @javascript
    Scenario: Access a forbidden entity as Buser
      And the user "Buser" with credential "User Berlin"
      And I am logged in as "Buser"
      And the triple "Werk/Werke" "Frankfurter Dom" "Standort in/Standort von" "Ort/Orte" "Kreuzberg"
      When I go to the entity page for "Kreuzberg"
      Then I should see "verweigert"
      When I go to the entity page for "Frankfurter Dom"
      Then I should see "Frankfurter Dom"
      And I should see element "img[alt=Select]" within ".metadata"
      And I should see element "img[alt=Target]" within ".metadata"
      And I should not see element "img[alt=Pen]" within ".metadata"
      And I should not see element "img[alt=X]" within ".metadata"
      And I should see element "img[alt=Plus]" within ".layout_panel.left .relationships"
      And I should not see element ".relationship"


  @javascript
  Scenario Outline: cross_collection_actions (create relationship)
    And the user "<username>" with credential "<credential>"
    And I am logged in as "<username>"
    And the triple "Werk/Werke" "Frankfurter Dom" "Standort in/Standort von" "Ort/Orte" "Kreuzberg"
    And "Rathaus" is selected as current entity
    When I go to the new relationship page with target "<entity>"
    Then I should have access: <access>
    
    Examples:
      | username | credential      | entity          | access |
      | Fadmin   | Admin Frankfurt | Frankfurter Dom | yes    |
      | Fadmin   | Admin Frankfurt | Kreuzberg       | yes    |
      | Fadmin   | Admin Frankfurt | Neukölln        | yes    |
      
  Scenario: cross_collection_actions (edit relationship)
    And the user "Fadmin" with credential "Admin Frankfurt"
    And I am logged in as "Fadmin"
    And the triple "Werk/Werke" "Frankfurter Dom" "Standort in/Standort von" "Ort/Orte" "Kreuzberg"
    When I go to the edit relationship page for the first relationship
    Then I should have access: yes
    

  Scenario Outline: cross_collection_actions (mark entity)
    And the user "<username>" with credential "<credential>"
    And I am logged in as "<username>"
    And the triple "Werk/Werke" "Frankfurter Dom" "Standort in/Standort von" "Ort/Orte" "Kreuzberg"
    When I send the mark request for entity "<entity>"
    Then I should have access: <access>
    
    Examples:
      | username | credential      | entity          | access |
      | Fadmin   | Admin Frankfurt | Frankfurter Dom | yes    |
      | Fadmin   | Admin Frankfurt | Kreuzberg       | yes    |
      | Fadmin   | Admin Frankfurt | Neukölln        | yes    |
      

  Scenario Outline: cross_collection_actions (mark entity as current)
    And the user "<username>" with credential "<credential>"
    And I am logged in as "<username>"
    And the triple "Werk/Werke" "Frankfurter Dom" "Standort in/Standort von" "Ort/Orte" "Kreuzberg"
    When I send the mark as current request for entity "<entity>"
    Then I should have access: <access>
    
    Examples:
      | username | credential      | entity          | access |
      | Fadmin   | Admin Frankfurt | Frankfurter Dom | yes    |
      | Fadmin   | Admin Frankfurt | Kreuzberg       | yes    |
      | Fadmin   | Admin Frankfurt | Neukölln        | yes    |      

