Feature: Merge
  As a User
  In order to combine multiple entities into one
  I want to use a merge
  
  
  @javascript
  Scenario: Merge institutions with linked GKD entries
    Given I am logged in as "admin"
    And kind "Institution" has field "bossa_id" of type "Fields::String"
    And kind "Institution" has field "knd" of type "Fields::String"
    And the entity "Louvre (Paris)" of kind "Institution/Institutionen"
    And the entity "Louvre" of kind "Institution/Institutionen"
    And the entity "Louvre" has dataset value "12345" for "knd"
    And the entity "Louvre (Paris)" has dataset value "67890" for "knd"
    And the entity "Louvre" has dataset value "123" for "bossa_id"
    And the entity "Louvre (Paris)" has dataset value "456" for "bossa_id"
    And all entities of kind "Institution/Institutionen" are in the clipboard
    When I go to the clipboard page
    And I follow "all"
    And I follow "Merge"
    Then I should see "Knd"
    And I should see "BossaId"
    When I press "Save"
    Then entity "Louvre" should have dataset value "12345" for "knd"
    And entity "Louvre" should have dataset value "123" for "bossa_id"


  @javascript
  Scenario: Merge media
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    And the medium "spec/fixtures/image_b.jpg"
    And all entities of kind "Medium/Media" are in the clipboard
    And I go to the clipboard
    And I select "merge" from "clipboard_action"
    And I press "Send"
    And I click on element "input#entity_id_2"
    And I press "Save"
    Then I should be on the entity page for the last medium
    