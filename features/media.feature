Feature: Media
  In order to visualize certain contents
  As a user
  I want to be able to upload, transform and link media
  
  
  @javascript
  Scenario: Rotate an uploaded image
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    When I go to the entity page for the last medium
    And I follow "Rotate_cw"
    Then I should be on the entity page for the last medium
    
  
  @javascript
  Scenario: Previews for uploaded images
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    And all media are processed
    And I go to the root page
    And I go to the entity page for the last medium
    Then I should see element "img[src*='/media/images/preview/000/000/001/image.jpg']" within ".viewer"
    
    
  @javascript
  Scenario: Upload a video and watch it
    Given I am logged in as "admin"
    And the medium "spec/fixtures/video_a.m4v"
    When I go to the entity page for the last medium
    And I click on the player link
    Then I should see the video player
