'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalSignupCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalSignupCtrl', ['$scope', '$uibModalInstance', '$timeout', '$window', 'apiService', function($scope, $uibModalInstance, $timeout, $window, apiService) {

    var $ctrl = this;
    // console.log(groups);
    // $ctrl.people = people.data;
    // $ctrl.relationships = relationships.data;
    // $ctrl.relTypes = relTypes.data;
    // $ctrl.groups = groups.data;
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
      $uibModalInstance.close($ctrl.new);
    }

  }]);
