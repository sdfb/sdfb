Feature: Find network
  Background: Basic seed data exists
    Given required app users exist
    And the "has met" relationship type exists with id 4

  Scenario: Finding the shared network of two people
    Given multiple people exist
    And each person has a unique relationship
    And each person has met a specified given person
    When I access the shared network api endpoint for those people
    And I am given json
    Then the data includes a list of relationships
    And the json is valid JSON-API
    And the data contains the relationships of each person
