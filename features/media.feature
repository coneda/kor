Feature: Media
  Scenario: Rotate an uploaded image
    Given I am logged in as "admin"
    When I go to the entity page for the last medium
    Then image ".viewer img" should have landscape orientation
    And I follow "rotate clockwise"
    Then I should be on the entity page for the last medium
    And I should see "has been transformed"
    Then image ".viewer img" should have portrait orientation
  
  Scenario: Upload a video and watch it
    Given I am logged in as "admin"
    And the medium "video_a"
    And everything is processed
    When I go to the entity page for the last medium
    And I follow "larger"
    Then I should see the video player

  Scenario: Change the collection of an existing medium entity
    Given I am logged in as "admin"
    And I go to the entity page for medium "picture_a"
    Then I should see "medium"
    When I follow "edit"
    And I select "private" from "Collection"
    And I press "Save"
    Then I should see "has been changed"
    And medium "picture_a" should be in collection "private"

  Scenario: display medium file type
    Given I am logged in as "admin"
    When I go to the new entries page
    Then I should see "New entries"
    Then I should see "File type: image/jpeg"
