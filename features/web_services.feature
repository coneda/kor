Feature: Web Services
  As a user
  In order to benefit from information within other sources
  I want to use web services
  
  
  Scenario: Add web services to a kind
    Given I am logged in as "admin"
    And the kind "Person/Personen"
    When I go to the kinds page
    And I follow "Pen" within the row for "kind" "Person"
    And I select "Amazon" from "kind[settings][web_services][]"
    And I press "Speichern"
    And I follow "Pen" within the row for "kind" "Person"
    Then I should see element "option[value=amazon][selected]"
    