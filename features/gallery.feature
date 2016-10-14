Feature: Show media in the gallery and show certain related entities
  In order to give a better overview of the stored entities
  Users should be able to
  use the gallery

  @javascript
  Scenario: View an empty gallery
    Given I am logged in as "admin"
    When I go to the gallery
    Then I should see "No entries found"
  

  @javascript
  Scenario: View the gallery
    Given I am logged in as "admin"
    And Leonardo, Mona Lisa and a medium as correctly related entities
    When I go to the gallery
    Then I should see "New entries"
    And I should see "Leonardo da Vinci"
    And I should see "Mona Lisa"
    And I should not see "Mona Lisa ()"
    
    
  @javascript
  Scenario: View the gallery (unauthorized)
    Given I am logged in as "admin"
    And Leonardo, Mona Lisa and a medium as correctly related entities
    And I re-login as "john"
    When I go to the gallery
    Then I should see "New entries"
    Then I should not see "Mona Lisa"
    And I should not see "Leonardo"
    
  
  @javascript
  Scenario: View gallery when no secondary relationships exist
    Given I am logged in as "admin"
    And Mona Lisa and a medium as correctly related entities
    When I go to the gallery
    Then I should not see "Leonardo da Vinci"


  @javascript
  Scenario: View gallery when no secondary relationships exist
    Given I am logged in as "admin"
    And Mona Lisa and a medium as correctly related entities
    And I wait for "1" second
    When I go to the gallery
    Then I should see "New entries" within ".canvas"
    And I should not see "Leonardo da Vinci"
    And I should see "Mona Lisa"
    And I should not see "Mona Lisa ()"


  @javascript
  Scenario: View the gallery (unauthorized)
    Given I am logged in as "admin"
    And Leonardo, Mona Lisa and a medium as correctly related entities
    And I re-login as "john"
    When I go to the gallery
    Then I should see "New entries"
    Then I should not see "Mona Lisa"
    And I should not see "Leonardo"
    
    
  @javascript
  Scenario: View gallery when no secondary relationships exist
    Given I am logged in as "admin"
    And Mona Lisa and a medium as correctly related entities
    When I go to the gallery
    Then I should not see "Leonardo da Vinci"
    And I should see "Mona Lisa"
    And I should not see "Mona Lisa ()"
