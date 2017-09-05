Feature: Type ahead group search
  Background: Basic seed data exists
    Given required app users exist
    And the "has met" relationship type exists with id 4
    And multiple groups exist

  Scenario: Searching for a group that exists
    Given I have a search string matching the name of an existing group
    When I access the type ahead endpoint with the search string, looking for a "group"
    And I am given json
    Then the data looks like a list of one group search result
    Then the data includes only results with names containing the search string

  Scenario: Searching for a group that does not exist
    Given I have an unlikely to match search string
    When I access the type ahead endpoint with the search string, looking for a "group"
    And I am given json
    Then the data looks like an empty list
