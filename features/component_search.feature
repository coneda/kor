@solr
Feature: Tag search
  As a user
  In order to find stuff I am looking for fast
  I want to search with Tags
  
  
  Background:
    Given I am logged in as "admin"
    And the entity "Frankreich" of kind "Werk/Werke"
    And the entity "Frankreich" has the tags "Land, Digitales Foto, Wein"
    And the entity "Deutschland" of kind "Werk/Werke"
    And the entity "Deutschland" has the tags "Land, Digitales Foto, Bier"
    And sunspot has indexed everything
    And I am on the simple search page
    
  
  @javascript
  Scenario: Search with partial terms
    When I fill in "search_terms" with "Deu" and select term "Deu"
    Then I should not see "Frankreich" within ".entity_list"
    And I should see "Deutschland" within ".entity_list"
    

  @javascript
  Scenario: Search with 1 Tag
    When I fill in "search_terms" with "Land" and select tag "Land"
    Then I should see "Frankreich" within ".entity_list"
    And I should see "Deutschland" within ".entity_list"


  @javascript
  Scenario: Search with 2 Tags
    When I fill in "search_terms" with "Land" and select tag "Land"
    And I fill in "search_terms" with "Wein" and select tag "Wein"
    Then I should see "Frankreich" within ".entity_list"
    And I should not see "Deutschland" within ".entity_list"
  

  @javascript
  Scenario: Search with 2 Tags with 2 words and two hits
    When I fill in "search_terms" with "Land" and select tag "Land"
    And I fill in "search_terms" with "Digitales Foto" and select tag "Digitales Foto"
    Then I should see "Frankreich" within ".entity_list"
    And I should see "Deutschland" within ".entity_list"


  @javascript
  Scenario: Search with 2 Tags with 2 words and one hit
    When I fill in "search_terms" with "Bier" and select tag "Bier"
    And I fill in "search_terms" with "Digitales Foto" and select tag "Digitales Foto"
    Then I should see "Deutschland" within ".entity_list"
    And I should not see "Frankreich" within ".entity_list"
  

  @javascript
  Scenario: Search with 2 Tags with 2 words and one hit otherwayround
    When I fill in "search_terms" with "Digitales Foto" and select tag "Digitales Foto"
    Then I should see "Frankreich" within ".entity_list"
    And I should see "Deutschland" within ".entity_list"
    When I fill in "search_terms" with "Wein" and select tag "Wein"
    Then I should see "Frankreich" within ".entity_list"
    And I should not see "Deutschland" within ".entity_list"
   
   
  @javascript
  Scenario: Simple search with synonyms
    Given the entity "Landschaft" of kind "Werk/Werke"
    And the entity "Landschaft" has the synonyms "Baum im Feld/Schöner Baum"
    And the entity "Hans" of kind "Person/Personen"
    And the entity "Hans" has the synonyms "Waldmeister/Baum im Feld"
    And sunspot has indexed everything
    
    And I am on the simple search page
    
    When I select "alle" from "kind_id"
    And I fill in "search_terms" with "Baum im Feld" and select term "Baum im Feld"
    Then I should see "Landschaft" within ".entity_list"
    And I should see "Hans" within ".entity_list"

    When I click on ".submit input.reset"
    And I select "Werk" from "kind_id"
    And I fill in "search_terms" with "Baum im Feld" and select term "Baum im Feld"
    Then I should see "Landschaft" within ".entity_list"
    And I should not see "Hans" within ".entity_list"

    When I click on ".submit input.reset"
    And I select "Person" from "kind_id"
    And I fill in "search_terms" with "Baum im Feld" and select term "Baum im Feld"
    Then I should not see "Landschaft" within ".entity_list"
    And I should see "Hans" within ".entity_list"
    
    When I click on ".submit input.reset"
    And I select "alle" from "kind_id"
    And I fill in "search_terms" with "Landschaft" and select term "Landschaft"
    And I fill in "search_terms" with "Waldmeister" and select term "Waldmeister"
    Then I should not see "Landschaft" within ".entity_list"
    And I should not see "Hans" within ".entity_list"
    
    When I click on ".submit input.reset"
    And I select "alle" from "kind_id"
    And I fill in "search_terms" with "Baum im Feld" and select term "Baum im Feld"
    And I fill in "search_terms" with "Hans" and select term "Hans"
    Then I should not see "Landschaft" within ".entity_list"
    And I should see "Hans" within ".entity_list"
    
    When I click on ".submit input.reset"
    And I select "Werk" from "kind_id"
    And I fill in "search_terms" with "Baum im Feld" and select term "Baum im Feld"
    And I fill in "search_terms" with "Hans" and select term "Hans"
    Then I should not see "Landschaft" within ".entity_list"
    And I should not see "Hans" within ".entity_list"
    
    
  @javascript
  Scenario: Paginate entities when there are more than 10 results
    Given there are "11" entities named "Auferstehung X" of kind "Werk/Werke"
    And sunspot has indexed everything
    When I go to the simple search page
    And I fill in "search_terms" with "Auferst" and select term "Auferst"
    Then I should see "von 2" within ".pagination:first-child"
    
  
  @javascript
  Scenario: Simple search with synonyms
    Given the relation "ist neben/ist neben"
    And the relationship "Frankreich" "ist neben" "Deutschland"
    And the entity "Frankreich" has the synonyms "La France"
    And sunspot has indexed everything
    And I fill in "search_terms" with "France" and select term "France"
    Then I should see "Deutschland" within ".entity_list"
    
    
