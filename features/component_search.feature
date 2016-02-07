Feature: Tag search
  As a user
  In order to find stuff I am looking for fast
  I want to search with Tags
  
  Background:
    Given I am logged in as "admin"
    And I am on the simple search page

  @javascript @elastic
  Scenario: Paginate entities when there are more than 10 results
    Given there are "11" entities named "Auferstehung X" of kind "Werk/Werke"
    And everything is indexed
    When I go to the simple search page
    And I fill in "search_terms" with "Auferst" and select term "Auferst"
    Then I should see "of 2" within ".pagination:first-child"
    