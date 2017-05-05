Feature: Find group
  Background: Basic seed data exists
    Given required app users exist
    And the "has met" relationship type exists with id 4

  Scenario: Finding a given group with the API
    Given a group exists
    When I access the api endpoint for the group
    Then I am given json that looks a group
    And the json has correct information for the group

  Scenario: Finding multiple groups with the API
    Given multiple groups exist
    When I access the api endpoint for those groups
    Then I am given json that looks a list containing 2 groups
    And the json has correct ids for those groups

  Scenario: Finding a group with an invalid ID
    When I access the api endpoint for a group with an invalid ID
    Then I am given a json error telling me "Invalid group ID(s)"
