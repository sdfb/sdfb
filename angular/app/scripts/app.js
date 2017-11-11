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
  // .config(function ($routeProvider) {
  //   $routeProvider
  //     .when('/', {
  //       redirectTo: '/visualization'
  //     })
  //     .when('/visualization', {
  //       templateUrl: 'views/visualization.html',
  //       // templateUrl: function(params) {return 'views/visualization.html?ids='+params.ids},
  //       controller: 'VisualizationCtrl',
  //       controllerAs: 'Visualization',
  //       resolve: {
  //         initialConfig: function(){
  //           return {
  //             viewObject:0, //0 = people, 1 = groups
  //             viewMode:'individual-force',
  //             // viewMode:'all',
  //             ids: 10000473,
  //             title: 'undefined title',
  //             networkComplexity: '2',
  //             dateMin:1500,
  //             dateMax:1700,
  //             confidenceMin:60,
  //             confidenceMax:100,
  //             login: {
  //               status: true,
  //               user: 'Elizabeth',
  //             },
  //             contributionMode: false,
  //             dateTypes : ['IN', 'CIRCA', 'BEFORE', 'BEFORE/IN','AFTER', 'AFTER/IN'],
  //             onlyMembers: false
  //           }
  //         },
  //         initialData: function(apiService) {
  //           return apiService.getFile('./data/baconnetwork.json');
  //         }
  //       }
  //     })
  //     .when('/table', {
  //       templateUrl: 'views/table.html',
  //       controller: 'TableCtrl',
  //       controllerAs: 'Table'
  //     })
  //     .when('/modal', {
  //       templateUrl: 'views/modal.html',
  //       controller: 'ModalCtrl',
  //       controllerAs: 'Modal'
  //     })
  //     .otherwise({
  //       redirectTo: '/visualization'
  //     });
  // });

redesign2017App.config(function($stateProvider, $locationProvider, $compileProvider) {
  var homeState = {
    name: 'home',
    url: '/',
    component: 'home',
    redirectTo: { state: 'home.visualization', params: { ids: '10000473', type: 'network' } }
    // abstract: true
  }
  var vizState = {
    name: 'home.visualization',
    url: '?ids&type',
    resolve: {
      networkData: ['apiService', '$stateParams', function(apiService, $stateParams) {
        if ($stateParams.ids.length < 8 && $stateParams.type === 'network') {
          return apiService.getGroupNetwork($stateParams.ids).then(function(result){
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
          return apiService.getNetwork($stateParams.ids).then(function(result){
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

              // var $ctrl = this;
              $scope.user = user.data;

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
            resolve: {
              token: ['$stateParams', 'apiService', function($stateParams, apiService) {
                console.log($stateParams.token);
                return $stateParams.token;
              }]
            },
            controller: ['$scope', 'apiService', function($scope, apiService) {
              $scope.dismiss = function() {
                $scope.$dismiss();
              };

              $scope.save = function() {
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
