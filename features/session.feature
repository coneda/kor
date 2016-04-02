Feature: Session
  In order to not have to authenticate for every page
  As a user
  I want to use a session


  @javascript
  Scenario: An expired session should lead to an expressive error message
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "artwork/artworks"
    When the session has expired
    And I go to the entity page for "Mona Lisa"
    Then I should see "Access denied"


  @javascript
  Scenario: The session panel should display media correctly when the current entity changes
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    And the entity "The Last Supper" of kind "artwork/artworks"
    When I go to the entity page for the last medium
    Then I should see "medium 1"
    When I click element "td.commands"
    And I should not see an image within "#session_info"
    And I click element "[data-name=select]"
    And I wait for "1" second
    And I should see an image within "#session_info"
    When I go to the entity page for "The Last Supper"
    And I should see "The Last Supper"
    And I should see an image within "#session_info"
    And I click element "[data-name=select]"
    And I should see an image within "#session_info"
    And I should see "The Last Supper" within "#session_info"
