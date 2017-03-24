Feature: Deleting Unapproved Group Assignments
  Background: Basic data exists
    Given required app users exist
    And a curator user exists
    And a person exists
    And a group exists

  Scenario: Deleting an unapproved group assignment as a curator
    Given a person has been added to a group
    Then the curator is able to delete the group assignment

  Scenario: Rejecting an unapproved group assignment as a curator
    Given a person has been added to a group
    Then the curator is able to reject the group assignment

  Scenario: Rejecting an unapproved relationship
    Given a person has been added to a group
    Then it is possible to reject the group assignment