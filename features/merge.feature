Feature: Merge
  As a User
  In order to combine multiple entities into one
  I want to use a merge
  
  
  @javascript
  Scenario: Merge institutions with linked GKD entries
    Given I am logged in as "admin"
    And kind "Institution" has field "bossa_id" of type "Fields::String"
    And kind "Institution" has web service "knd"
    And the entity "Louvre" of kind "Institution/Institutionen"
    And the entity "Louvre (Paris)" of kind "Institution/Institutionen"
    And the entity "Louvre" has external reference "knd" like "12345"
    And the entity "Louvre (Paris)" has external reference "knd" like "67890"
    And the entity "Louvre" has dataset value "123" for "bossa_id"
    And the entity "Louvre (Paris)" has dataset value "456" for "bossa_id"
    And all entities of kind "Institution/Institutionen" are in the clipboard
    When I go to the clipboard page
    And I select "verschmelzen" from "clipboard_action"
    And I press "Senden"
    Then I should see "GND-ID"
    And I should see "BossaId"
    When I press "Erstellen"
    Then entity "Louvre" should have external_reference value "12345" for "knd"
    And entity "Louvre" should have dataset value "123" for "bossa_id"
