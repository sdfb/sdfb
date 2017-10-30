'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:HomeCtrl
 * @description
 * # VisualizationCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App').component('home', {
  // bindings: { networkData: '<' },
  templateUrl: 'views/home.html',
  controller: ['$scope', '$stateParams', '$uibModal', '$log', '$cookieStore', 'apiService', function($scope, $stateParams, $uibModal, $log, $cookieStore, apiService) {
    $scope.config = {
      contributionMode: false,
      layout: 'individual-force',
      login: {
        status: false,
        user: 'Elizabeth',
      }
    };

    function init() {
      var session = $cookieStore.get('session');
      if (session) {
        $scope.user = session;
      }
    }

    init();

    $scope.openCurate = function(size, parentSelector) {
      var parentElem = parentSelector ?
        angular.element($document[0].querySelector('.modal-demo ' + parentSelector)) : undefined;
      var modalInstance = $uibModal.open({
        animation: $scope.modalAnimationsEnabled,
        ariaLabelledBy: 'modal-curate',
        ariaDescribedBy: 'modal-curate-body',
        templateUrl: './views/modal-curate.html',
        controller: 'ModalCurateCtrl',
        controllerAs: '$ctrl',
        size: size,
        appendTo: parentElem,
        resolve: {
          people: function() {
            return apiService.curatePeople($scope.user.auth_token).then(function(result) {
              return result;
            });
          },
          relationships: function() {
            return apiService.curateRelationships($scope.user.auth_token).then(function(result) {
              return result;
            });
          },
          relTypes: function() {
            return apiService.curateRelTypes($scope.user.auth_token).then(function(result) {
              return result;
            });
          },
          groups: function() {
            return apiService.curateGroups($scope.user.auth_token).then(function(result) {
              return result;
            });
          }
        }
      });
      modalInstance.result.then(function(result) {
        console.log(result);
        // apiService.writeData(result);
      }, function() {
        $log.info('Modal dismissed at: ' + new Date());
      });
    };

	}]
});
