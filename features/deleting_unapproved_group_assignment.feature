Feature: Deleting Unapproved Group Assignment
  Background: Basic seed data exists
    Given required app users exist
    And a curator user exists
    And the "has met" relationship type exists with id 4
    And the "has eaten" relationship type exists with id 99

  Scenario: Creating an unapproved relationship as a curator
    Given a relationship exists
    And there is unapproved "has eaten" relationship
    Then the "has eaten" relationship should exist

  Scenario: Deleting an unapproved relationship as a curator
    Given a relationship exists
    And there is unapproved "has eaten" relationship
    Then the curator can delete the "has eaten" relationship