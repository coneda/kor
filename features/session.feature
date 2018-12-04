Feature: Session
  Scenario: An expired session should lead to an expressive error message
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "artwork/artworks"
    When the session has expired
    And I go to the entity page for "Mona Lisa"
    Then I should see "Access denied"
