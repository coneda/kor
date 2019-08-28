Feature: Capybara framework
  # We check that relevant browser aspects (cookies, local storage) are
  # indeed refreshed after each scenario

  Scenario:
    Given I am logged in as "admin"
    And I set local storage "x" to "hello"
    And I go to url "https://google.com"

  Scenario:
    Given I am on the home page
    Then I should not be logged in
    And local storage "x" should be empty
