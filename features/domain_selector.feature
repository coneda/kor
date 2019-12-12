Feature: domain selector
  Scenario: One domain available
    And I am logged in as "jdoe"
    And I am on the search page
    Then I should not see "Domains" within "form"
    When I fill in "Name" with "Mona Lisa"
    And I press "Search"
    Then I should see "Mona Lisa" within "kor-search-result"

  Scenario: Three domains available
    And I am logged in as "admin"
    When I am on the search page
    Then I should see "Domains: all"
    When I follow "edit" within "kor-collection-selector"
    Then checkbox "Default" should be checked
    Then checkbox "private" should be checked
    When I press "ok"
    And I press "Search"
    Then I should see "Mona Lisa" within ".search-results"
    And I should see "The Last Supper" within ".search-results"
    
  Scenario: Search only one domain
    And I am logged in as "admin"
    When I am on the search page
    And I select "private" from the collections selector
    And I press "Search"
    Then I should see "The Last Supper"
    And I should not see "Mona Lisa"
