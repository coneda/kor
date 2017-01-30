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
    And I should <seeselectb> element "a[kor-current-button]" within ".metadata"
    And I should <seetargetb> element "a[kor-to-clipboard]" within ".metadata"
    And I should <seepenb> element "img[data-name=pen]" within ".metadata"
    And I should <seexb> element "img[data-name=x]" within ".metadata"
    And I should <seeplusb> element "img[data-name=plus]" within ".layout_panel.left .relationships"
    And I should <seerelb> "Frankfurter Dom" within ".relationship"
    When I go to the entity page for "Frankfurter Dom"
    Then I should see "<seef>"
    And I should <seeselectf> element "a[kor-current-button]" within ".metadata"
    And I should <seetargetf> element "a[kor-to-clipboard]" within ".metadata"
    And I should <seepenf> element "img[data-name=pen]" within ".metadata"
    And I should <seexf> element "img[data-name=x]" within ".metadata"
    And I should <seeplusf> element "img[data-name=plus]" within ".layout_panel.left .relationships"
    And I should <seerelf> element ".relationship"
    And I should <seerelpenf> element "img[data-name=pen]" within ".relationship.stage_panel"

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
      Then I should see "Access denied"
      When I go to the entity page for "Frankfurter Dom"
      Then I should see "Frankfurter Dom"
      And I should see element "a[kor-current-button]" within ".metadata"
      And I should see element "a[kor-to-clipboard]" within ".metadata"
      And I should not see element "img[data-name=pen]" within ".metadata"
      And I should not see element "img[data-name=x]" within ".metadata"
      And I should see element "img[data-name=plus]" within ".layout_panel.left .relationships"
      And I should not see element ".relationship"


  @javascript
  Scenario Outline: cross_collection_actions (mark entity)
    And the user "<username>" with credential "<credential>"
    And I am logged in as "<username>"
    And the triple "Werk/Werke" "Frankfurter Dom" "Standort in/Standort von" "Ort/Orte" "Kreuzberg"
    When I mark "<entity>" as current entity
    Then I should have access: <access>
    
    Examples:
      | username | credential      | entity          | access |
      | Fadmin   | Admin Frankfurt | Frankfurter Dom | yes    |
      | Fadmin   | Admin Frankfurt | Kreuzberg       | yes    |
      | Fadmin   | Admin Frankfurt | Neukölln        | yes    |
      

  @javascript
  Scenario Outline: cross_collection_actions (mark entity as current)
    And the user "<username>" with credential "<credential>"
    And I am logged in as "<username>"
    And the triple "Werk/Werke" "Frankfurter Dom" "Standort in/Standort von" "Ort/Orte" "Kreuzberg"
    When I mark "<entity>" as current entity
    Then I should have access: <access>
    
    Examples:
      | username | credential      | entity          | access |
      | Fadmin   | Admin Frankfurt | Frankfurter Dom | yes    |
      | Fadmin   | Admin Frankfurt | Kreuzberg       | yes    |
      | Fadmin   | Admin Frankfurt | Neukölln        | yes    |      

