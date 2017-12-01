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

    relationships.data.forEach(function(d) {
      apiService.getUserName(d.attributes.created_by).then(function(result) {
        d.attributes.created_by_name = result.data.username;
      });
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

    var filteredRelTypes = angular.copy(relTypes.data);
    filteredRelTypes = filteredRelTypes.filter(function(d) { return d.attributes.created_by !== 3; });

    filteredRelTypes.forEach(function(d) {
      apiService.getUserName(d.attributes.created_by).then(function(result) {
        d.attributes.created_by_name = result.data.username;
      });
      relTypes.included.forEach(function(i) {
        if (i.id === d.attributes.relationship.attributes.person_1.toString()) {
          d.attributes.relationship.attributes.person_1_name = i.attributes.name;
        }
        if (i.id === d.attributes.relationship.attributes.person_2.toString()) {
          d.attributes.relationship.attributes.person_2_name = i.attributes.name;
        }
      })
    });
    $ctrl.relTypes = filteredRelTypes;

    $ctrl.groups = groups.data;
    $ctrl.groups.forEach(function(g) {
      apiService.getUserName(g.attributes.created_by).then(function(result) {
        g.attributes.created_by_name = result.data.username;
      });
    })

    group_assignments.data.forEach(function(d) {
      apiService.getUserName(d.attributes.created_by).then(function(result) {
        d.attributes.created_by_name = result.data.username;
      });
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

    $ctrl.cancel = function() {
      $uibModalInstance.dismiss('cancel');
    };

    $ctrl.submit = function() {
      $ctrl.addToDB = {}
      $ctrl.addToDB.auth_token = $rootScope.user.auth_token;
      $ctrl.addToDB.nodes = [];
      $ctrl.people.forEach(function (p, i) {
        var newPerson = {};
        newPerson.id = parseInt(p.id);
        newPerson.name = p.attributes.name;
        newPerson.historical_significance = p.attributes.historical_significance;
        newPerson.citations = p.attributes.citations;
        newPerson.is_approved = p.is_approved;
        newPerson.is_active = !p.is_dismissed;
        if (newPerson.is_approved || newPerson.is_active === false) {
          $ctrl.addToDB.nodes.push(newPerson);
          $ctrl.people.splice(i,1);
        }
      });
      $ctrl.addToDB.relationships = [];
      $ctrl.relationships.forEach(function(r, i) {
        var newRelationship = {};
        newRelationship.id = parseInt(r.id);
        newRelationship.is_approved = r.is_approved;
        newRelationship.is_active = !r.is_dismissed;
        newRelationship.citations = r.attributes.citations;
        if (newRelationship.is_approved || newRelationship.is_active === false) {
          $ctrl.addToDB.relationships.push(newRelationship);
          $ctrl.relationships.splice(i,1);
        }
      });
      $ctrl.addToDB.relationshipAssignments = [];
      $ctrl.relTypes.forEach(function(r, i) {
        var newRelType = {};
        newRelType.id = parseInt(r.id);
        newRelType.is_approved = r.is_approved;
        newRelType.is_active = !r.is_dismissed;
        newRelType.citations = r.attributes.citations;
        if (newRelType.is_approved || newRelType.is_active === false) {
          $ctrl.addToDB.relationshipAssignments.push(newRelType);
          $ctrl.relTypes.splice(i,1);
        }
      });
      relTypes.data.forEach(function(r) {
        $ctrl.addToDB.relationships.forEach(function(rel) {
          if (rel.id === parseInt(r.attributes.relationship.id) && r.attributes.created_by === 3) {
            var newRelType = {};
            newRelType.id = parseInt(r.id);
            newRelType.is_approved = rel.is_approved;
            newRelType.is_active = rel.is_active;
            $ctrl.addToDB.relationshipAssignments.push(newRelType);
          }
        })
      });
      $ctrl.addToDB.groups = [];
      $ctrl.groups.forEach(function (g, i) {
        var newGroup = {};
        newGroup.id = parseInt(g.id);
        newGroup.is_approved = g.is_approved;
        newGroup.is_active = !g.is_dismissed;
        newGroup.name = g.attributes.name;
        newGroup.description = g.attributes.description;
        newGroup.citations = g.attributes.citations;
        if (newGroup.is_approved || newGroup.is_active === false) {
          $ctrl.addToDB.groups.push(newGroup);
          $ctrl.groups.splice(i,1);
        }
      });
      $ctrl.addToDB.group_assignments = [];
      $ctrl.group_assignments.forEach(function (g, i) {
        var newGroupAssign = {};
        newGroupAssign.id = parseInt(g.id);
        newGroupAssign.is_approved = g.is_approved;
        newGroupAssign.is_active = !g.is_dismissed;
        newGroupAssign.citations = g.attributes.citations;
        if (newGroupAssign.is_approved || newGroupAssign.is_active === false) {
          $ctrl.addToDB.group_assignments.push(newGroupAssign);
          $ctrl.group_assignments.splice(i,1);
        }
      });

      apiService.writeData($ctrl.addToDB).then(function(result) {
        $scope.curateSuccess = true;
      }, function(error) {
        console.error("An error occured while fetching file",error);
        $scope.curateFailure = true;
      });
      // $uibModalInstance.close($ctrl.addToDB);
    }

  }]);
