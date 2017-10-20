'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalReviewCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalReviewCtrl', ['$scope', '$uibModalInstance', '$timeout', 'addToDB', '$window', 'apiService', function($scope, $uibModalInstance, $timeout, addToDB, $window, apiService) {

    var $ctrl = this;
    $ctrl.addToDB = addToDB;
    // $ctrl.sendData = sendData;

    $ctrl.remove = function(index, list) {
      list.splice(index,1);
    };

    $ctrl.ok = function() {
      $uibModalInstance.close($ctrl.selected.group);
    };

    $ctrl.cancel = function() {
      console.log('dismiss')
      $uibModalInstance.dismiss('cancel');
    };

    console.log($scope.$parent.data);

    $ctrl.sendData = function() {
      console.log($ctrl.addToDB);
      apiService.writeData($ctrl.addToDB);
    }

    // $ctrl.sendData = function() {
    //   console.log($ctrl.addToDB);
    //   addToDB = {nodes: [], links: [], groups: []};
    //   $scope.newNode = {};
    //   $scope.$parent.newLink = {};
    //   $scope.$parent.newGroup = {};
    //   $scope.$parent.groupAssign = {person: {}, group: {}};
    //   $scope.$parent.addedNodeId = 0;
    //   $window.alert("Updates Submitted! They'll show up on the website once they've been approved by a curator.")
    // }

  }]);
