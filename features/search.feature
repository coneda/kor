Feature: search
  @elastic
  Scenario: set criteria from url
    Given I am logged in as "admin"
    And I go to the path "/#/search?name=leonardo&kind_id=2&dataset_gnd_id=123456789"
    Then I should see field "Name" with value "leonardo"
    And I should see field "GND-ID" with value "123456789"
    And I should see "Leonardo" within ".search-results"
    And I should not see "Mona Lisa" within ".search-results"

  @elastic
  Scenario: search by name
    Given I am logged in as "admin"
    And I go to the search page
    Then I should see "Search"
    When I fill in "Name" with "mona"
    And I press "Search"
    Then I should see "Mona Lisa" within ".search-results"
    Then I should not see "Leonardo" within ".search-results"

  @elastic
  Scenario: Transmit search criteria
    Given I am logged in as "admin"
    And I am on the search page
    Then I should see "Search"
    And I should see "Mona Lisa" within ".search-results"
    When I select "person" from "Entity type"
    Given the search api expects to receive the params
      | name           | value    |
      | kind_id        | 2        |
      | except_kind_id | 1        |
      | terms          | leonardo |
      | name           | mona     |
      | dataset_gnd_id | 12345    |
      | tags           | free     |
      | dating         | 1988     |
      | property       | 32       |
      | related        | some     |
    When I fill in "Everywhere" with "leonardo"
    And I fill in "Name" with "mona"
    And I fill in "GND-ID" with "12345"
    And I fill in "Tags" with "free"
    And I fill in "Dating" with "1988"
    And I fill in "Further properties" with "32"
    And I fill in "Search in related entities" with "some"
    And I press "Search"
    And I follow "Edit profile"
    And I should see "Edit profile"

  Scenario: no elasticsearch available
    Given I am logged in as "admin"
    And I am on the search page
    Then I should see "Search"
    When I select "person" from "Entity type"
    Then I should not see field "Everywhere"
    And I should not see field "GND-ID"
    And I should not see field "Properties"

  @notravis
  Scenario: using browser back function to restore previous criteria and results
    Given I am logged in as "admin"
    And I am on the search page
    Then I should see "Collections: all"
    Then I should see "Search"
    When I fill in "Name" with "mona"
    When I follow "edit" within "kor-collection-selector"
    And I uncheck "Default"
    When I press "ok"
    Then I should see "Collections: private"
    When I press "Search"
    And I go back
    Then I should see "Collections: all" within widget "kor-collection-selector"
