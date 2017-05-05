Feature: Find person
  Background: Basic seed data exists
    Given required app users exist
    And the "has met" relationship type exists with id 4

  Scenario: Finding a given person with the API
    Given a person exists
    When I access the api endpoint for the person
    Then I am given json that looks a person
    And the json has correct information for the person
