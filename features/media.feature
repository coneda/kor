Feature: Media
  In order to visualize certain contents
  As a user
  I want to be able to upload, transform and link media
  
  
  @javascript
  Scenario: Rotate an uploaded image
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    And everything is processed
    When I go to the entity page for the last medium
    And I wait for "2" seconds
    And I follow "Rotate_cw"
    Then I should be on the entity page for the last medium
    
  
  @javascript
  Scenario: Previews for uploaded images
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    And everything is processed
    And I go to the root page
    And I go to the entity page for the last medium
    Then I should see element "img[src*='/media/images/preview/000/000/001/image.jpg']" within ".viewer"
    
    
  @javascript
  Scenario: Upload a video and watch it
    Given I am logged in as "admin"
    And the medium "spec/fixtures/video_a.m4v"
    And everything is processed
    When I go to the entity page for the last medium
    And I click on the player link
    Then I should see the video player


  @javascript
  Scenario: Change the collection of an existing medium entity
    Given the collection "side collection"
    And "admins" are allowed to "view/create/edit" collection "side collection"
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    And I go to the entity page for the last medium
    Then I should see "medium"
    When I click on element "img[data-name=pen]"
    And I select "side collection" from "entity[collection_id]"
    And I press "Save"
    Then I should not see "Errors occurred"

  @javascript
  Scenario: display medium file type
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    When I go to the welcome page
    Then I should see "File type: jpeg"
    When I go to the new entries page
    Then I should see "File type: jpeg"
    When I go to the isolated entities page
    Then I should see "File type: jpeg"