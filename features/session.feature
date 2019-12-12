Feature: Session
  Scenario: An expired session should lead to an expressive error message
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "artwork/artworks"
    When I travel "3.hours"
    And I go to the entity page for "Mona Lisa"
    Then I should see "Access denied"

  Scenario: update the menu when the session is expired
    Given I am logged in as "admin"
    When I travel "3.hours"
    And I follow "Personal collections"
    Then I should see "You are not logged in"
    And I should not see "Personal collections" within widget "kor-menu"
