'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalReviewCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalReviewCtrl', ['$scope', '$uibModalInstance', '$timeout', 'addToDB', '$window', 'apiService', '$rootScope', 'addedNodes', 'addedGroups', 'addedLinks', '$http', function($scope, $uibModalInstance, $timeout, addToDB, $window, apiService, $rootScope, addedNodes, addedGroups, addedLinks, $http) {

    var $ctrl = this;
    $ctrl.addToDB = addToDB;
    $ctrl.addedNodes = addedNodes;
    $ctrl.addedGroups = addedGroups;
    $ctrl.addedLinks = addedLinks;
    // $ctrl.sendData = sendData;

    // scope.config.relTypeCats = null;
    $http.get("/data/rel_cats.json").then(function(result){
        var relTypeCats = result.data;
        $ctrl.addToDB.links.forEach(function(l) {
          relTypeCats.forEach(function(t) {
            if (t.id === l.relType) {
              l.relTypeName = t.name;
            }
          });
        });
    });

    console.log()

    $ctrl.remove = function(index, list1, list2) {
      list1.splice(index,1);
      if (list2 !== undefined) {
        list2.splice(index,1);
      }
    };

    $ctrl.ok = function() {
      $uibModalInstance.close($ctrl.selected.group);
    };

    $ctrl.cancel = function() {
      // console.log('dismiss')
      $uibModalInstance.dismiss($ctrl.addToDB);
    };

    $ctrl.submit = function() {
      $ctrl.addToDB.auth_token = $rootScope.user.auth_token;

      $ctrl.addToDB.links.forEach (function(l) {
        delete l.id;
      })
      $uibModalInstance.close($ctrl.addToDB);

    }

  }]);
