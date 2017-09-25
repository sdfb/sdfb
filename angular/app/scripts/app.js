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

redesign2017App.config(function($stateProvider, $locationProvider) {
  var homeState = {
    name: 'home',
    url: '/',
    component: 'visualization'
    // resolve: {
    //   data: function(apiService, $transition$) {
    //     var ids = $transition$.params().ids;
    //     return apiService.getNetwork(ids);//.then(function(result) {
    //     //   console.log('person network of',ids,'\n',result);
    //     //   return result;
    //     //   // result.layout = 'individual-force';
    //     //   // $scope.config.viewMode = 'individual-force';
    //     //   // $scope.$broadcast('force layout generate', result);
    //     //   // $scope.data4groups();
    //     // });
    //   }
    // }
  }
  var forceState = {
    name: 'home.forceLayout',
    url: '?ids',
    resolve: {
      networkData: function(apiService, $stateParams) {
          console.log($stateParams.ids);
          return apiService.getNetwork($stateParams.ids).then(function(result){
            apiService.result = result;
            return apiService.result;
          });
      }
    },
    component: 'forceLayout'
  }

  $stateProvider.state(homeState);
  $stateProvider.state(forceState);
  $locationProvider.html5Mode(true);
})
