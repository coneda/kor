Feature: Cross collection relationships & permissions
  Scenario Outline: cross_collection_interface
    Given the setup "Frankfurt-Berlin"
    And the user "<username>" with credential "<credential>"
    And I am logged in as "<username>"
    And the triple "Werk/Werke" "Frankfurter Dom" "Standort in/Standort von" "Ort/Orte" "Kreuzberg"
    When I go to the entity page for "Kreuzberg"
    Then I should see "<seeb>"
    And I should <seetargetb> element "a.to-clipboard" within ".page-commands"
    And I should <seepenb> link "edit" within ".page-commands"
    And I should <seexb> link "delete" within ".page-commands"
    And I should <seeplusb> link "add relationship"
    And I should <seerelb> "Frankfurter Dom" within ".relations"
    When I go to the entity page for "Frankfurter Dom"
    Then I should see "<seef>"
    And I should <seetargetf> element "a.to-clipboard" within ".page-commands"
    And I should <seepenf> link "edit" within ".page-commands"
    And I should <seexf> link "delete" within ".page-commands"
    And I should <seeplusf> link "add relationship"
    And I should <seerelpenf> link "edit" within ".kor-layout-left .relations"

    Examples:
      | username | credential      | seeb       | seeselectb | seetargetb | seepenb | seexb   | seeplusb | seerelb | seef | seeselectf | seetargetf | seepenf | seexf   | seeplusf | seerelf | seerelpenf |
      | Fuser    | User Frankfurt  | Kreuzberg  | not see    | see        | not see | not see | not see  | see     | Dom  | not see    | see        | not see | not see | not see  | see     | not see    |

  Scenario Outline: cross_collection_interface
    Given the setup "Frankfurt-Berlin"
    And the user "<username>" with credential "<credential>"
    And I am logged in as "<username>"
    And the triple "Werk/Werke" "Frankfurter Dom" "Standort in/Standort von" "Ort/Orte" "Kreuzberg"
    When I go to the entity page for "Kreuzberg"
    Then I should see "<seeb>"
    And I should <seetargetb> element "a.to-clipboard" within ".page-commands"
    And I should <seepenb> link "edit" within ".page-commands"
    And I should <seexb> link "delete" within ".page-commands"
    And I should <seeplusb> link "add relationship"
    And I should <seerelb> "Frankfurter Dom" within ".relations"
    When I go to the entity page for "Frankfurter Dom"
    Then I should see "<seef>"
    And I should <seetargetf> element "a.to-clipboard" within ".page-commands"
    And I should <seepenf> link "edit" within ".page-commands"
    And I should <seexf> link "delete" within ".page-commands"
    And I should <seeplusf> link "add relationship"
    And I should <seerelpenf> link "edit" within ".kor-layout-left .relations"

    Examples:
      | username | credential      | seeb       | seeselectb | seetargetb | seepenb | seexb   | seeplusb | seerelb | seef | seeselectf | seetargetf | seepenf | seexf   | seeplusf | seerelf | seerelpenf |
      | Fadmin   | Admin Frankfurt | Kreuzberg  | see        | see        | not see | not see | see      | see     | Dom  | see        | see        | see     | see     | see      | see     | see        |

  Scenario Outline: cross_collection_interface
    Given the setup "Frankfurt-Berlin"
    And the user "<username>" with credential "<credential>"
    And I am logged in as "<username>"
    And the triple "Werk/Werke" "Frankfurter Dom" "Standort in/Standort von" "Ort/Orte" "Kreuzberg"
    When I go to the entity page for "Kreuzberg"
    Then I should see "<seeb>"
    And I should <seetargetb> element "a.to-clipboard" within ".page-commands"
    And I should <seepenb> link "edit" within ".page-commands"
    And I should <seexb> link "delete" within ".page-commands"
    And I should <seeplusb> link "add relationship"
    And I should <seerelb> "Frankfurter Dom" within ".relations"
    When I go to the entity page for "Frankfurter Dom"
    Then I should see "<seef>"
    And I should <seetargetf> element "a.to-clipboard" within ".page-commands"
    And I should <seepenf> link "edit" within ".page-commands"
    And I should <seexf> link "delete" within ".page-commands"
    And I should <seeplusf> link "add relationship"
    And I should <seerelpenf> link "edit" within ".kor-layout-left .relations"

    Examples:
      | username | credential      | seeb       | seeselectb | seetargetb | seepenb | seexb   | seeplusb | seerelb | seef | seeselectf | seetargetf | seepenf | seexf   | seeplusf | seerelf | seerelpenf |
      | Badmin   | Admin Berlin    | Kreuzberg  | see        | see        | see     | see     | see      | see     | Dom  | see        | see        | not see | not see | see      | see     | see        |

  Scenario: Access a forbidden entity as Buser
    Given I am logged in as "jdoe"
    When I go to the entity page for "The Last Supper"
    Then I should see "Access denied"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I should see link "add to clipboard" within ".page-commands"
    And I should not see link "edit" within ".page-commands"
    And I should not see link "delete" within ".page-commands"
    And I should not see link "add relationship"
    And I should not see "The Last Supper"
