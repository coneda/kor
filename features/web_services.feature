Feature: Web Services
  As a user
  In order to benefit from information within other sources
  I want to use web services
  
  
  Scenario: Add web services to a kind
    Given I am logged in as "admin"
    And the kind "Person/Personen"
    When I go to the kinds page
    And I follow "Pen" within the row for "kind" "Person"
    And I select "Coneda Information Service" from "kind[settings][web_services][]"
    And I press "Speichern"
    And I follow "Pen" within the row for "kind" "Person"
    Then I should see element "option[value=coneda_information_service][selected]"
    
  
  @javascript
  Scenario: Add the coneda information service
    Given I am logged in as "admin"
    And the kind "Person/Personen"
    When I go to the kinds page
    And I follow "Pen" within the row for "kind" "Person"
    And I select "Coneda Information Service" from "kind[settings][web_services][]"
    And I press "Speichern"
    When I go to the new "Person-Entity" page
    And I fill in "entity[name]" with "Julia Roberts"
    And I fill in "entity[external_references][pnd]" with "119077744"
    And I press "Erstellen"
    And I wait for "2" seconds
    And I follow "Pen"
    Then the "entity[external_references][pnd]" field should contain "119077744"
    When I follow "Plus" within "#synonyms"
    And I fill in "entity[synonyms][]" with "Die Schönste"
    And I press "Speichern"
    And I wait for "2" seconds
    And I follow "Pen"
    Then the "entity[external_references][pnd]" field should contain "119077744"
    And the "entity[synonyms][]" field should contain "Die Schönste"
    When I follow "Plus" within "#synonyms"
    When I fill in element "input[name='entity[synonyms][]']" with index "1" with "Die Beste"
    And I press "Speichern"
    Then I should see "Die Beste"
    And I should see "Die Schönste"
    And I should see "Coneda Information Service"
    When I follow "Pen"
    Then the "entity[external_references][pnd]" field should contain "119077744"
    And the element "input[name='entity[synonyms][]']" with index "0" should contain "Die Schönste"
    And the element "input[name='entity[synonyms][]']" with index "1" should contain "Die Beste"
