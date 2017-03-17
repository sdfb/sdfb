Feature: Setting default dates
  Background: Basic seed data exists
    Given required app users exist

  Scenario: Adding a person to a group
    Given a person exists
    And a group exists
    And I know when the person joined and departed the group
    When I assign the person to the group
    Then a group membership is created for the person and the group
    And the group membership's start date is the known group assignment start date
    And the group membership's start date type is the known group assignment start date type
    And the group membership's end date is the known group assignment end date
    And the group membership's end date type is the known group assignment end date type

  Scenario: Adding a person to a group without knowing assignment start and end dates
    Given a person exists
    And a group exists
    And the group started before the person was born
    And the group ended after the person died
    And I do not know when the person joined or departed the group
    When I assign the person to the group
    Then a group membership is created for the person and the group
    And the group membership's start date is the person's birth date
    And the group membership's start date type is "AF/IN"
    And the group membership's end date is the person's death date
    And the group membership's end date type is "BF/IN"

  Scenario: Adding a person to a group without knowing their birth date
    Given a person exists
    And a group exists
    And the person has an unknown birth date
    And the person has an unknown death date
    And I do not know when the person joined or departed the group
    When I assign the person to the group
    Then a group membership is created for the person and the group
    And the group membership's start date is the group's start date
    And the group membership's start date type is "AF/IN"
    And the group membership's end date is the group's end date
    And the group membership's end date type is "BF/IN"

  Scenario: Adding a person to a group without knowing any dates
    Given a person exists
    And a group exists
    And the group has an unknown start date
    And the group has an unknown end date
    And the person has an unknown birth date
    And the person has an unknown death date
    And I do not know when the person joined or departed the group
    When I assign the person to the group
    Then a group membership is created for the person and the group
    And the group membership's start date is the Earliest Year
    And the group membership's start date type is "AF/IN"
    And the group membership's end date is the Latest Year
    And the group membership's end date type is "BF/IN"

  Scenario: Trying to assign a person to a group after the group existed
    Given a person exists
    And a group exists
    And I know when the person joined and departed the group
    And the start date I choose is after the group existed
    When I assign the person to the group
    Then the assignment is invalid

  Scenario: Trying to assign a person to a group before the group existed
    Given a person exists
    And a group exists
    And I know when the person joined and departed the group
    And the start date I choose is before the group existed
    When I assign the person to the group
    Then the assignment is invalid

  Scenario: Trying to assign a person to a group before the person existed
    Given a person exists
    And a group exists
    And I know when the person joined and departed the group
    And the start date I choose is before the person existed
    When I assign the person to the group
    Then the assignment is valid

  Scenario: Trying to assign a person to a group after the person existed
    Given a person exists
    And a group exists
    And I know when the person joined and departed the group
    And the start date I choose is after the person existed
    When I assign the person to the group
    Then the assignment is valid

  Scenario: Trying to assign a person to a group with backward dates
    Given a person exists
    And a group exists
    And I know when the person joined and departed the group
    And the start date I choose is after the end date I choose
    When I assign the person to the group
    Then the assignment is invalid
