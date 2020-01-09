Feature: Cloning

Scenario: create a clone from an existing entity
  Given I am logged in as "admin"
  And "Entity" "Leonardo" has these attributes
    | attribute     | value    |
    | distinct_name | da Vinci |
    | subtype       | painter  |
  And I go to the entity page for "Leonardo"
  And I click "clone"
  Then I should see "Create person"
  And field "Name" should have value "Leonardo"
  And field "Distinguished name" should have value "da Vinci"
  And field "Type" should have value "painter"
  And field "GND-ID" should have value "123456789"
  And field "Synonyms" should have value "Leo"
  And field "Type of dating" should have value "Lifespan"
  And field "Dating" should have value "1452 bis 1519"
  And field "Further properties" should have value "Epoche: Renaissance"

  When I click "Save"
  Then I should see "the input contains errors"
  When I fill in "Name" with "Other Leonardo"
  And I fill in "Distinguished name" with ""
  And I click "Save"
  Then I should see "has been created"
