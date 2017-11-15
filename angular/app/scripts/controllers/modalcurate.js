'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalCurateCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalCurateCtrl', ['$scope', '$uibModalInstance', '$timeout', '$window', 'apiService', 'people', 'relationships', 'relTypes', 'groups', 'group_assignments', '$rootScope', function($scope, $uibModalInstance, $timeout, $window, apiService, people, relationships, relTypes, groups, group_assignments, $rootScope) {

    var $ctrl = this;
    $ctrl.people = people.data;

    $ctrl.people.forEach(function(p) {
      apiService.getUserName(p.attributes.created_by).then(function(result) {
        p.attributes.created_by_name = result.data.username;
      });
    })

    console.log($ctrl.people);

    relationships.data.forEach(function(d) {
      relationships.included.forEach(function(i) {
        if (i.id === d.attributes.person_1.toString()) {
          d.attributes.person_1_name = i.attributes.name;
        }
        if (i.id === d.attributes.person_2.toString()) {
          d.attributes.person_2_name = i.attributes.name;
        }
      })
    });
    $ctrl.relationships = relationships.data;

    relTypes.data.forEach(function(d) {
      relTypes.included.forEach(function(i) {
        if (i.id === d.attributes.relationship.attributes.person_1.toString()) {
          d.attributes.relationship.attributes.person_1_name = i.attributes.name;
        }
        if (i.id === d.attributes.relationship.attributes.person_2.toString()) {
          d.attributes.relationship.attributes.person_2_name = i.attributes.name;
        }
      })
    });
    $ctrl.relTypes = relTypes.data;

    $ctrl.groups = groups.data;

    group_assignments.data.forEach(function(d) {
      group_assignments.includes.forEach(function(i) {
        if (i.id === d.attributes.person_id.toString()) {
          d.attributes.person_name = i.attributes.name;
        }
        if (i.id === d.attributes.group_id.toString()) {
          d.attributes.group_name = i.attributes.name;
        }
      })
    });
    $ctrl.group_assignments = group_assignments.data;
    // $ctrl.addToDB = addToDB;
    // $ctrl.sendData = sendData;

    // $ctrl.remove = function(index, list) {
    //   list.splice(index,1);
    // };

    // $ctrl.ok = function() {
    //   $uibModalInstance.close($ctrl.selected.group);
    // };

    $ctrl.cancel = function() {
      console.log('dismiss')
      $uibModalInstance.dismiss('cancel');
    };

    $ctrl.close = function() {
      $ctrl.addToDB = {}
      $ctrl.addToDB.auth_token = $rootScope.user.auth_token;
      $ctrl.addToDB.nodes = [];
      $ctrl.people.forEach(function (p) {
        var newPerson = {};
        newPerson.id = parseInt(p.id);
        // newPerson.name = p.attributes.name;
        // newPerson.birthDate = p.attributes.birth_year;
        // newPerson.birthDateType = p.attributes.birth_year_type;
        // newPerson.deathDate = p.attributes.death_year;
        // newPerson.deathDateType = p.attributes.death_year_type;
        // newPerson.gender = p.attributes.gender;
        // newPerson.historical_significance = p.attributes.historical_significance;
        newPerson.is_approved = p.is_approved;
        newPerson.is_active = !p.is_dismissed;
        if (newPerson.is_approved || newPerson.is_active === false) {
          $ctrl.addToDB.nodes.push(newPerson);
        }
      });
      $ctrl.addToDB.links = [];
      // $ctrl.relationships.forEach(function(r) {
      //   var newRelationship = {};
      //   newRelationship.id = parseInt(r.id);
      //   newRelationship.is_approved = r.is_approved;
      //   if (newRelationship.is_approved) {
      //     $ctrl.addToDB.links.push(newRelationship);
      //   }
      // })
      $ctrl.addToDB.groups = [];
      $ctrl.groups.forEach(function (g) {
        var newGroup = {};
        newGroup.id = parseInt(g.id);
        // newPerson.name = p.attributes.name;
        // newPerson.birthDate = p.attributes.birth_year;
        // newPerson.birthDateType = p.attributes.birth_year_type;
        // newPerson.deathDate = p.attributes.death_year;
        // newPerson.deathDateType = p.attributes.death_year_type;
        // newPerson.gender = p.attributes.gender;
        // newPerson.historical_significance = p.attributes.historical_significance;
        newGroup.is_approved = g.is_approved;
        newGroup.is_active = !g.is_dismissed;
        if (newGroup.is_approved || newGroup.is_active === false) {
          $ctrl.addToDB.groups.push(newGroup);
        }
      });
      $ctrl.addToDB.group_assignments = [];
      $ctrl.group_assignments.forEach(function (g) {
        var newGroupAssign = {};
        newGroupAssign.id = parseInt(g.id);
        // newPerson.name = p.attributes.name;
        // newPerson.birthDate = p.attributes.birth_year;
        // newPerson.birthDateType = p.attributes.birth_year_type;
        // newPerson.deathDate = p.attributes.death_year;
        // newPerson.deathDateType = p.attributes.death_year_type;
        // newPerson.gender = p.attributes.gender;
        // newPerson.historical_significance = p.attributes.historical_significance;
        newGroupAssign.is_approved = g.is_approved;
        newGroupAssign.is_active = !g.is_dismissed;
        if (newGroupAssign.is_approved || newGroupAssign.is_active === false) {
          $ctrl.addToDB.group_assignments.push(newGroupAssign);
        }
      });

      // apiService.writeData($ctrl.addToDB);
      $uibModalInstance.close($ctrl.addToDB);
    }

  }]);
