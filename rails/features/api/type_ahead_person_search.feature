Feature: Type ahead person search
  Background: Basic seed data exists
    Given required app users exist
    And the "has met" relationship type exists with id 4
    And multiple people exist

  Scenario: Searching for a person that exists
    Given I have a search string matching the name of an existing person
    When I access the type ahead endpoint with the search string, looking for a "person"
    And I am given json
    Then the data looks like a list of one person search result
    Then the data includes only results with names containing the search string

  Scenario: Searching for a person that does not exist
    Given I have an unlikely to match search string
    When I access the type ahead endpoint with the search string, looking for a "person"
    And I am given json
    Then the data looks like an empty list