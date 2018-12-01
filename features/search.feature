Feature: search
  Scenario: set criteria from url
    Given I am logged in as "admin"
    And I go to the path "/#/search?name=leonardo&kind_id=2&dataset_gnd_id=123456789"
    Then I should see field "Name" with value "leonardo"
    And I should see field "GND-ID" with value "123456789"
    And I should see "Leonardo" within ".search-results"
    And I should not see "Mona Lisa" within ".search-results"

  Scenario: search by name
    Given I am logged in as "admin"
    And I go to the search page
    Then I should see "Search"
    When I fill in "Name" with "mona"
    And I press "Search"
    Then I should see "Mona Lisa" within ".search-results"
    Then I should not see "Leonardo" within ".search-results"

  Scenario: Transmit search criteria
    Given I am logged in as "admin"
    And I am on the search page
    Then I should see "Search"
    And I should see "Mona Lisa" within ".search-results"
    When I select "person" from "Entity type"
    Given the search api expects to receive the params
      | name           | value    |
      | terms          | leonardo |
      | name           | mona     |
      | dataset_gnd_id | 12345    |
    When I fill in "Terms" with "leonardo"
    And I fill in "Name" with "mona"
    And I fill in "GND-ID" with "12345"
    And I press "Search"

  # TODO: continue here


  Scenario: search (elasticsearch available)
    Given I am logged in as "admin"
    And I am on the search page
    Then I should see "Search"
    And I should see field "Dating"
    When I select "person" from "Entity type"
    Then I should see field "GND-ID"
    And I should see field "Wikidata ID"

    When I fill in "GND-ID" with "123456789"
    And I press "Search"
    Then I should see "Leonardo" within ".search-results"
    And I should not see "Mona Lisa" within ".search-results"

  Scenario: no elasticsearch available
    Given elasticsearch is not available
    And I am logged in as "admin"
    And I am on the search page
    Then I should see "Search"
    When I select "person" from "Entity type"
    Then I should not see field "Terms"
    And I should not see field "Dating"
    And I should not see field "GND-ID"

  # Scenario: 
  #   # Given elasticsearch is available
  #   # And I reload the page
  #   # Then I should see field "Dating"

  Scenario: show and hide dataset fields when elasticsearch is available
    Given I am logged in as "admin"
    And I go to the search page
    And I debug

  Scenario: do simple search based on title
    Given I am logged in as "admin"
    Given the entity "Bamberg" of kind "Ort/Orte"
    And the entity "Bamberger Apokalypse" of kind "Werk/Werke"
    When I go to the simple search page
    And I fill in "search_terms" with "Bamberg"
    And I press the "enter" key
    Then I should see "Bamberg" within ".entity_list"
    And I should see "Bamberger Apokalypse" within ".entity_list"

  
  @javascript
  Scenario: do exact simple search
    Given I am logged in as "admin"
    Given the entity "Bamberger Apokalypse" of kind "Werk/Werke"
    When I go to the simple search page
    And I fill in "search_terms" with "Bamberger Apokalypse"
    Then I should be on the simple search page


  @javascript @wip
  Scenario: do simple search based on relationship
    Given I am logged in as "admin"
    Given the triple "Werk/Werke" "Bamberger Apokalypse" "befindet sich in/ist Ort von" "Ort/Orte" "Bamberg"
    When I go to the simple search page
    And I fill in "search_terms" with "Apokalypse"
    And I press "Search"
    Then I should see "Bamberg" within ".entity_list"
    And I should see "Bamberger Apokalypse" within ".entity_list"


  Scenario: do expert search
    Given I am logged in as "admin"
    Given the entity "Bamberg" of kind "Ort/Orte"
    And the entity "Bamberger Apokalypse" of kind "Werk/Werke"
    When I go to the expert search page
    And I fill in "query[name]" with "Bamberg"
    And I press "Search"
    Then I should see "Bamberg" within ".entity_list"
    And I should see "Bamberger Apokalypse" within ".entity_list"


  Scenario: do exact expert search
    Given I am logged in as "admin"
    Given the entity "Bamberger Apokalypse" of kind "Werk/Werke"
    When I go to the expert search page
    And I fill in "query[name]" with "Bamberger Apokalypse"
    And I press "Search"
    Then I should be on the expert search path
    
    
  @javascript @elastic
  Scenario: case insensitive search within synonyms
    Given I am logged in as "admin"
    And the entity "Oedipus" of kind "Werk/Werke"
    And the entity "Oedipus" has the synonyms "Ödipus"
    And everything is indexed
    When I go to the expert search
    And I fill in "query[name]" with "ödipus"
    And I press "Search"
    Then I should see "Oedipus" within ".search_result"


  @javascript @elastic
  Scenario: Search by dataset values
    Given I am logged in as "admin"
    And kind "Literatur/Literaturen" has field "isbn" of type "Fields::Isbn"
    And the entity "Die Bibel" of kind "Literatur/Literaturen"
    And the entity "Die Bibel" has dataset value "123456789" for "isbn"
    When I go to the expert search page
    And I select "Literatur" from "query[kind_id]"
    Then I should see "Isbn"
    When I press "Search"
    Then I should see "Die Bibel" within ".search_result"
    When I fill in "query[dataset][isbn]" with "incorrect"
    When I press "Search"
    Then I should not see "Die Bibel"
    When I fill in "query[dataset][isbn]" with "123456789"
    When I press "Search"
    Then I should see "Die Bibel" within ".search_result"


  @javascript @elastic
  Scenario: Search by property label and value
    Given I am logged in as "admin"
    And the entity "Die Bibel" of kind "Literatur/Literaturen"
    And the entity "Die Bibel" has property "isbn" with value "123456789"
    And everything is indexed
    When I go to the expert search page
    And I select "Literatur" from "query[kind_id]"
    When I fill in "query[properties]" with "incorrect"
    When I press "Search"
    Then I should not see "Die Bibel"
    When I fill in "query[properties]" with "123456789"
    When I press "Search"
    Then I should see "Die Bibel" within ".search_result"
    When I fill in "query[properties]" with "isbn"
    When I press "Search"
    Then I should see "Die Bibel" within ".search_result"


  @javascript @elastic
  Scenario: Put search results into the clipboard and remove them
    Given the entity "Mona Lisa" of kind "Werk/Werke"
    And everything is indexed
    And I am logged in as "admin"
    When I go to the simple search page
    And I fill in "search_terms" with "Mona" and select term "Mona"
    And I click on element "input" within the row for "entity" "Mona Lisa"
    Then I should see "has been copied to the clipboard"
    When I click on element "input" within the row for "entity" "Mona Lisa"
    Then I should see "has been removed from the clipboard"


  @javascript @elastic
  Scenario: Search for media wit tags
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    And the last entity has the tags "some, image"
    When I go to the simple search page
    And I fill in "search_terms" with "some"
    And I wait for "2" seconds
    Then I should not see "some (1)"

  
  @javascript @elastic
  Scenario: Search for additional criteria
    Given I am logged in as "admin"
    And the triple "Werk/Werke" "Bamberger Apokalypse" "befindet sich in/ist Ort von" "Ort/Orte" "Bamberg"
    And I go to the expert search page
    When I select "Werk" from "query_kind_id"
    And I should see element ".entity_list"
    And I click element "[data-name=plus]"
    And I select "befindet sich in" from "query_relationships__relation_name"
    And I fill in "query_relationships__entity_name" with "Bamberg"
    And I press "Search"
    Then I should see "Bamberger Apokalypse" within ".search_result"


  @javascript
  Scenario: Expert search: see results after kind selection
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "Werk/Werke"
    When I go to the expert search page
    And I select "Werk" from "query[kind_id]"
    Then I should see "Mona Lisa" within ".entity_list"
