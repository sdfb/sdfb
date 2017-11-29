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
  controller: ['$scope', '$stateParams', '$uibModal', '$log', '$cookieStore', 'apiService', '$rootScope', '$http', '$transitions', '$window', function($scope, $stateParams, $uibModal, $log, $cookieStore, apiService, $rootScope, $http, $transitions, $window) {
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
        $rootScope.user = session;
      }
    }

    init();

    $rootScope.config = {};
    $rootScope.config.viewMode = 'individual-force';

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
            return apiService.curatePeople($rootScope.user.auth_token).then(function(result) {
              return result;
            });
          },
          relationships: function() {
            return apiService.curateRelationships($rootScope.user.auth_token).then(function(result) {
              return result;
            });
          },
          relTypes: function() {
            return apiService.curateRelTypes($rootScope.user.auth_token).then(function(result) {
              return result;
            });
          },
          groups: function() {
            return apiService.curateGroups($rootScope.user.auth_token).then(function(result) {
              return result;
            });
          },
          group_assignments: function() {
            return apiService.curateGroupAssignments($rootScope.user.auth_token).then(function(result) {
              return result;
            });
          }
        }
      });
      modalInstance.result.then(function(data) {
        // console.log(JSON.stringify(data));
        // apiService.writeData(data);
        // var url = 'http://sixdegr-dev.library.cmu.edu/tools/api/write';
        // return $http({
        //   method: 'POST',
        //   url: url,
        //   data: angular.toJson(data)
        // }).then(function successCallback(response){
        //   return response;
        // },function errorCallback(response){
        //   console.error("An error occured while fetching file",response);
        //   console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
        //   return response;
        // });
      }, function() {
        $log.info('Modal dismissed at: ' + new Date());
      });
    };

    $scope.openSignup = function(size, parentSelector) {
      var parentElem = parentSelector ?
        angular.element($document[0].querySelector('.modal-demo ' + parentSelector)) : undefined;
      var modalInstance = $uibModal.open({
        animation: $scope.modalAnimationsEnabled,
        ariaLabelledBy: 'modal-signup',
        ariaDescribedBy: 'modal-signup-body',
        templateUrl: './views/modal-signup.html',
        controller: 'ModalSignupCtrl',
        controllerAs: '$ctrl',
        size: size,
        appendTo: parentElem
      });
      modalInstance.result.then(function(result) {
        console.log(result);
        apiService.newUser(result);
      }, function() {
        $log.info('Modal dismissed at: ' + new Date());
      });
    };

    $scope.openResetRequest = function(size, parentSelector) {
      var parentElem = parentSelector ?
        angular.element($document[0].querySelector('.modal-demo ' + parentSelector)) : undefined;
      var modalInstance = $uibModal.open({
        animation: $scope.modalAnimationsEnabled,
        ariaLabelledBy: 'modal-request',
        ariaDescribedBy: 'modal-request-body',
        templateUrl: './views/modal-request.html',
        controller: 'ModalRequestCtrl',
        controllerAs: '$ctrl',
        size: size,
        appendTo: parentElem
      });
      modalInstance.result.then(function(result) {
        console.log(result);
        apiService.requestReset(result);
      }, function() {
        $log.info('Modal dismissed at: ' + new Date());
      });
    };

    $rootScope.openEditPerson = function(personId, size, parentSelector) {
      console.log(personId);
      var parentElem = parentSelector ?
        angular.element($document[0].querySelector('.modal-demo ' + parentSelector)) : undefined;
      var modalInstance = $uibModal.open({
        animation: $scope.modalAnimationsEnabled,
        ariaLabelledBy: 'modal-edit-person',
        ariaDescribedBy: 'modal-edit-person-body',
        templateUrl: './views/modal-edit-person.html',
        controller: 'ModalEditPersonCtrl',
        controllerAs: '$ctrl',
        size: size,
        appendTo: parentElem,
        resolve: {
          person: function() {
            return apiService.getPeople(personId).then(function(result) {
              return result;
            });
          }
        }
      });
      modalInstance.result.then(function(result) {
        console.log(result);
        var toDB = {nodes: [result], auth_token: $rootScope.user.auth_token}
        apiService.writeData(toDB).then(function successCallback(response) {
          console.log('success!');
          $rootScope.personEditSuccess = true;
        }, function errorCallback(error) {
          console.log(error);
          $rootScope.personEditFailure = true;
        });
      }, function() {
        $log.info('Modal dismissed at: ' + new Date());
      });
    };

    $transitions.onBefore({}, function(transition) {
      console.log(transition);
      if ($scope.config.contributionMode) {
        if ($window.confirm("If you leave this page without submitting your changes, they will be lost. If you'd like to leave anyway, click 'okay'?")) {
          return true;
        } else {
          return false;
        }
      }
    });

	}]
});
