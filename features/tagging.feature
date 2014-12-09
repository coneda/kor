Feature: tagging
  In order to group entities
  As an editor
  I want to tag them


  @javascript
  Scenario: Hide inplace controls without relevant rights
    # Given user "guest" is allowed to "tagging" collection "default" via credential "guests"
    Given I am logged in as "admin"
    And Mona Lisa and a medium as correctly related entities
    Given the user "guest"
    Given user "guest" is allowed to "view" collection "default" via credential "guests"
    When I follow "Abmelden"
    When I go to the entity page for "Mona Lisa"
    Then I should not see element ".inplace_container a"


  @javascript
  Scenario: Show inplace controls given the user has the rights
    Given I am logged in as "admin"
    And Mona Lisa and a medium as correctly related entities
    Given the user "guest"
    Given user "guest" is allowed to "view" collection "default" via credential "guests"
    Given user "guest" is allowed to "tagging" collection "default" via credential "guests"
    When I follow "Abmelden"
    When I go to the entity page for "Mona Lisa"
    Then I should see element ".inplace_container a"