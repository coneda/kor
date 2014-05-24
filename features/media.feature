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
  Scenario: Buttonbar quick buttons
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    When I go to the gallery page
    And I hover element ".kor_medium_frame"
    And I wait for "1" seconds
    And I click on ".kor_medium_frame img[alt=Target]"
    Then I should see "Zwischenablage aufgenommen"
    And I hover element ".kor_medium_frame"
    And I wait for "1" second
    When I click on ".kor_medium_frame img[alt=Target_hit]"
    And I wait for "2" seconds
    Then I should see "Zwischenablage entfernt"
    

  @javascript
  Scenario: Previews for uploaded images
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    When I go to the entity page for the last medium
    Then I should see element "img[src*='/media/images/preview/000/000/001/image.jpg']" within ".viewer"
    
    
  @javascript
  Scenario: Upload a video and watch it
    Given I am logged in as "admin"
    And the medium "spec/fixtures/video_a.m4v"
    When I go to the entity page for the last medium
    And I click on the player link
    Then I should see the video player
