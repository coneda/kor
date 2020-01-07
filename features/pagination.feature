Feature: Pagination
  As a user
  In order not to be overwhelmed with results
  I want to paginate through them
  
  
  @javascript @nodelay
  Scenario: Paginate 11 search results and paginate back
    Given I am logged in as "admin"
    And there are "11" entities named "Werk X" of kind "Werk/Werke"
    When I go to the expert search page
    And I select "Werk" from "query[kind_id]"
    And I fill in "query[name]" with "Werk"
    And I press "Search"
    And I click element "img[data-name=pager_right]"
    Then I should see "Search results"
    And I should see "Werk 9"
    When I click element "img[data-name=pager_left]"
    And I should see "Werk 1"

  
  @javascript @nodelay
  Scenario: Paginate 33 items on the gallery
    Given I am logged in as "admin"
    And there are "33" media entities
    When I go to the gallery
    Then I should see "16" gallery items
    And the current js page should be "1"
    And I wait for "0.2" seconds
    When I click element "img[data-name='pager_right']"
    And I should see "16" gallery items
    And the current js page should be "2"
    And I wait for "0.2" seconds
    When I click element "img[data-name='pager_right']"
    And I should see "1" gallery item
    And the current js page should be "3"

    When I click the first gallery item
    Then I should see "text/plain"
    When I go back
    And I should see "1" gallery item
    And the current js page should be "3"

    And I wait for "0.2" seconds
    When I click element "img[data-name='pager_left']"
    And the current js page should be "2"
    And I should see "16" gallery items

    When I fill in "page" with "1" within ".pagination"
    And I press "go to"
    And I should see "16" gallery items
    And the current js page should be "1"


  @javascript @nodelay
  Scenario: Go to specific page directly
    Given I am logged in as "admin"
    And there are "17" media entities
    When I go to page "2" of the gallery
    And I should see "1" gallery item
    And the current js page should be "2"