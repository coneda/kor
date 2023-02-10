Feature: Pagination

  @elastic
  Scenario: Paginate 11 search results and paginate back
    Given I am logged in as "admin"
    And there are "11" entities named "work %02d" of kind "work/works"
    And everything is indexed
    When I go to the search page
    And I select "work" from "Entity type"
    And I press "Search"
    Then I should see "13 results"
    Then I should see "work 00"
    And I should see "work 07"
    And I follow "next" within "kor-pagination.top"
    Then I should not see "work 07"
    And I should see "work 10"
    When I follow "previous" within "kor-pagination.top"
    Then I should see "work 00"
    And I should see "work 07"
    And I should not see "work 10"

  Scenario: Paginate 33 items on the gallery
    Given I am logged in as "admin"
    And there are "31" media entities
    When I go to the gallery
    Then I should see "16" gallery items
    And the current js page should be "1"
    And I wait for "0.2" seconds
    When I follow "next" within "kor-pagination.top"
    And I should see "16" gallery items
    And the current js page should be "2"
    And I wait for "0.2" seconds
    When I follow "next" within "kor-pagination.top"
    And I should see "1" gallery item
    And the current js page should be "3"

    And I wait for "1" second
    And I should see "1" gallery item
    When I click the first gallery item
    Then I should see "image/jpeg"
    When I go back
    And the current js page should be "3"

    And I wait for "0.2" seconds
    When I follow "previous" within "kor-pagination.top"
    And the current js page should be "2"
    And I should see "16" gallery items

    When I fill in "page" with "1" within "kor-pagination.top"
    And I press "go to" within "kor-pagination.top"
    And I should see "16" gallery items
    And the current js page should be "1"

  Scenario: Go to specific page directly
    Given I am logged in as "admin"
    And there are "15" media entities
    When I go to page "2" of the gallery
    And I should see "1" gallery item
    And the current js page should be "2"