'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalCurateCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalCurateCtrl', ['$scope', '$uibModalInstance', '$timeout', '$window', 'apiService', 'people', 'relationships', 'relTypes', 'groups', function($scope, $uibModalInstance, $timeout, $window, apiService, people, relationships, relTypes, groups) {

    var $ctrl = this;
    console.log(groups);
    $ctrl.people = people.data;
    $ctrl.relationships = relationships.data;
    $ctrl.relTypes = relTypes.data;
    $ctrl.groups = groups.data;
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
      $ctrl.addToDB.nodes = $ctrl.people;
      $ctrl.addToDB.links = $ctrl.relationships;
      $ctrl.addToDB.groups = $ctrl.groups;
      $uibModalInstance.close($ctrl.addToDB);
    }

  }]);
