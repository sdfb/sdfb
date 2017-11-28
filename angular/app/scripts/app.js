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
            apiService.result = result.data;
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
            apiService.result = result.data;
            return apiService.result;
          }, function(error) {
            console.log("THIS IS AN ERROR");
            console.error("An error occured while fetching file",error);
            return "error";
          });
        }
      }]
    },
    component: 'visualization'
  }
  var peopleState = {
    name: 'home.people',
    url: 'people/{page}',
    resolve: {
      people: ['apiService', '$stateParams', function(apiService, $stateParams) {
        return apiService.getAllPeople(100,$stateParams.page).then(function(result){
          return result.data;
        });
      }]
    },
    component: 'people'
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
  var aboutState = {
    name: "home.about",
    url: "about",
    onEnter: ['$stateParams', '$state', '$uibModal', '$resource', function($stateParams, $state, $uibModal, $resource) {
        $uibModal.open({
            templateUrl: './views/modal-about.html',
            controller: ['$scope', function($scope) {
              $scope.dismiss = function() {
                $scope.$dismiss();
              };
            }]
        }).result.finally(function() {
            $state.go('^');
        });
    }]
  }
  var recentState = {
    name: "home.recent",
    url: "recent",
    onEnter: ['$stateParams', '$state', '$uibModal', '$resource', function($stateParams, $state, $uibModal, $resource) {
        $uibModal.open({
            templateUrl: './views/modal-recent.html',
            resolve: {
              recent: ['apiService', function(apiService) {
                return apiService.getRecent().then(function(result){
                  return result;
                })
              }]
            },
            controller: ['$scope', 'recent', 'apiService', function($scope, recent, apiService) {
              console.log(recent.data);
              recent = recent.data;
              $scope.people = recent.data.people;

              $scope.people.forEach(function(p) {
                apiService.getUserName(p.attributes.created_by).then(function(result) {
                  p.attributes.created_by_name = result.data.username;
                });
              })

              recent.data.relationships.forEach(function(d) {
                apiService.getUserName(d.created_by).then(function(result) {
                  d.created_by_name = result.data.username;
                });
                // recent.includes.forEach(function(i) {
                //   if (i.id === d.attributes.person_1.toString()) {
                //     d.attributes.person_1_name = i.attributes.name;
                //   }
                //   if (i.id === d.attributes.person_2.toString()) {
                //     d.attributes.person_2_name = i.attributes.name;
                //   }
                // })
              });
              $scope.relationships = recent.data.relationships;

              recent.data.links.forEach(function(d) {
                apiService.getUserName(d.attributes.created_by).then(function(result) {
                  d.attributes.created_by_name = result.data.username;
                });
                recent.includes.forEach(function(i) {
                  if (i.id === d.attributes.relationship.attributes.person_1.toString()) {
                    d.attributes.relationship.attributes.person_1_name = i.attributes.name;
                  }
                  if (i.id === d.attributes.relationship.attributes.person_2.toString()) {
                    d.attributes.relationship.attributes.person_2_name = i.attributes.name;
                  }
                })
              });
              $scope.relTypes = recent.data.links;

              $scope.groups = recent.data.groups;
              $scope.groups.forEach(function(g) {
                apiService.getUserName(g.attributes.created_by).then(function(result) {
                  g.attributes.created_by_name = result.data.username;
                });
              })

              recent.data.group_assignments.forEach(function(d) {
                apiService.getUserName(d.attributes.created_by).then(function(result) {
                  d.attributes.created_by_name = result.data.username;
                });
                recent.includes.forEach(function(i) {
                  if (i.id === d.attributes.person_id.toString()) {
                    d.attributes.person_name = i.attributes.name;
                  }
                  if (i.id === d.attributes.group_id.toString()) {
                    d.attributes.group_name = i.attributes.name;
                  }
                })
              });
              $scope.group_assignments = recent.data.group_assignments;
              $scope.dismiss = function() {
                $scope.$dismiss();
              };
            }]
        }).result.finally(function() {
            $state.go('^');
        });
    }]
  }
  var helpState = {
    name: "home.help",
    url: "help",
    onEnter: ['$stateParams', '$state', '$uibModal', '$resource', function($stateParams, $state, $uibModal, $resource) {
        $uibModal.open({
            templateUrl: './views/modal-help.html',
            controller: ['$scope', function($scope) {
              $scope.dismiss = function() {
                $scope.$dismiss();
              };
            }]
        }).result.finally(function() {
            $state.go('^');
        });
    }]
  }

  $stateProvider.state(homeState);
  $stateProvider.state(vizState);
  $stateProvider.state(peopleState);
  $stateProvider.state(userState);
  $stateProvider.state(resetState);
  $stateProvider.state(aboutState);
  $stateProvider.state(recentState);
  $stateProvider.state(helpState);
  $locationProvider.html5Mode(true);
  $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|data):/);
})

redesign2017App.run(function($rootScope) {
  $rootScope.$on("$stateChangeError", console.log.bind(console));
});
