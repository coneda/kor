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
    Then I should see "Zugriff wurde verweigert"