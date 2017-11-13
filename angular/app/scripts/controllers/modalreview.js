'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalReviewCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalReviewCtrl', ['$scope', '$uibModalInstance', '$timeout', 'addToDB', '$window', 'apiService', '$rootScope', 'addedNodes', 'addedGroups', 'addedLinks', function($scope, $uibModalInstance, $timeout, addToDB, $window, apiService, $rootScope, addedNodes, addedGroups, addedLinks) {

    var $ctrl = this;
    $ctrl.addToDB = addToDB;
    $ctrl.addedNodes = addedNodes;
    $ctrl.addedGroups = addedGroups;
    $ctrl.addedLinks = addedLinks;
    // $ctrl.sendData = sendData;

    $ctrl.remove = function(index, list1, list2) {
      list1.splice(index,1);
      list2.splice(index,1);
    };

    $ctrl.ok = function() {
      $uibModalInstance.close($ctrl.selected.group);
    };

    $ctrl.cancel = function() {
      // console.log('dismiss')
      $uibModalInstance.dismiss($ctrl.addToDB);
    };

    $ctrl.close = function() {
      $ctrl.addToDB.auth_token = $rootScope.user.auth_token;
      console.log(JSON.stringify($ctrl.addToDB));
      $uibModalInstance.close($ctrl.addToDB);
    }

  }]);
