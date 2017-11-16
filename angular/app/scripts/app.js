'use strict';

/**
 * @ngdoc overview
 * @name redesign2017App
 * @description
 * # redesign2017App
 *
 * Main module of the application.
 */
var redesign2017App = angular
  .module('redesign2017App', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    // 'ngRoute',
    'ngSanitize',
    'ngTouch',
    'ui.bootstrap',
    'ui.router',
    'angular-loading-bar',
    'rzModule'
  ]);

redesign2017App.config(function($stateProvider, $locationProvider, $compileProvider) {
  var homeState = {
    name: 'home',
    url: '/',
    component: 'home',
    redirectTo: { state: 'home.visualization', params: { ids: '10000473', type: 'network', min_confidence: 60 } }
    // abstract: true
  }
  var vizState = {
    name: 'home.visualization',
    url: '?ids&min_confidence&type',
    resolve: {
      networkData: ['apiService', '$stateParams', function(apiService, $stateParams) {
        if ($stateParams.ids.length < 8 && $stateParams.type === 'network') {
          return apiService.getGroupNetwork($stateParams.ids, $stateParams.min_confidence).then(function(result){
            apiService.result = result;
            return apiService.result;
          });
        } else if ($stateParams.ids.length < 8 && $stateParams.type === 'timeline') {
          return apiService.getGroups($stateParams.ids).then(function(result){
            apiService.result = result;
            return apiService.result;
          });
        } else if ($stateParams.type === 'all-groups') {
          return apiService.getAllGroups().then(function(result){
            apiService.result = result;
            return apiService.result;
          });
        } else {
          return apiService.getNetwork($stateParams.ids, $stateParams.min_confidence).then(function(result){
            apiService.result = result;
            return apiService.result;
          });
        }
      }]
    },
    component: 'visualization'
  }
  var tableState = {
    name: 'home.browse',
    url: 'browse',
    resolve: {
      tableData: ['$http', function($http) {
        return $http.get("/data/SDFB_people_2017_10_13.csv").then(function(result){
          return result.data;
        });
      }]
    },
    component: 'browse'
  }
  var userState = {
    name: "home.user",
    url: "user/{userId}",
    onEnter: ['$stateParams', '$state', '$uibModal', '$resource', function($stateParams, $state, $uibModal, $resource) {
        $uibModal.open({
            templateUrl: './views/modal-user.html',
            resolve: {
              user: ['$cookieStore', 'apiService', function($cookieStore, apiService) {
                var session = $cookieStore.get('session');
                var token = session.auth_token;
                var userId = $stateParams.userId;
                return apiService.getUser(userId,token).then(function(result){
                  return result;
                })
              }]
            },
            controller: ['$scope', 'user', function($scope, user) {

              // var $scope = this;
              $scope.user = user.data;
              console.log($scope.user);

              $scope.user.remaining = 100 - parseInt($scope.user.points);
              $scope.dismiss = function() {
                $scope.$dismiss();
              };

              $scope.close = function() {
                $scope.$close();
              };

              $scope.user_download = 'data:attachment/json;charset=utf-8,' +  encodeURIComponent(JSON.stringify($scope.user, null, 2));
            }]
        }).result.finally(function() {
            $state.go('^');
        });
    }]
  }
  var resetState = {
    name: "home.reset",
    url: "password_reset?token",
    onEnter: ['$stateParams', '$state', '$uibModal', '$resource', function($stateParams, $state, $uibModal, $resource) {
        $uibModal.open({
            templateUrl: './views/modal-reset.html',
            // resolve: {
            //   token: ['$stateParams', 'apiService', function($stateParams, apiService) {
            //     console.log($stateParams.token);
            //     return $stateParams.token;
            //   }]
            // },
            controller: ['$scope', 'apiService', '$stateParams', function($scope, apiService, $stateParams) {
              $scope.dismiss = function() {
                $scope.$dismiss();
              };



              $scope.save = function() {
                $scope.new.reset_token = $stateParams.token;
                apiService.resetPassword($scope.new).then(function() {
                  $scope.$close(true);
                });
              };
            }]
        }).result.finally(function() {
            $state.go('^');
        });
    }]
  }

  $stateProvider.state(homeState);
  $stateProvider.state(vizState);
  $stateProvider.state(tableState);
  $stateProvider.state(userState);
  $stateProvider.state(resetState);
  $locationProvider.html5Mode(true);
  $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|data):/);
})

redesign2017App.run(function($rootScope) {
  $rootScope.$on("$stateChangeError", console.log.bind(console));
});
