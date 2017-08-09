'use strict';

/**
 * @ngdoc overview
 * @name redesign2017App
 * @description
 * # redesign2017App
 *
 * Main module of the application.
 */
angular
  .module('redesign2017App', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'ui.bootstrap',
    'rzModule'
  ])
  .config(function ($routeProvider) {
    $routeProvider
      .when('/', {
        redirectTo: '/visualization'
      })
      .when('/visualization', {
        templateUrl: 'views/visualization.html',
        // templateUrl: function(params) {return 'views/visualization.html?ids='+params.ids},
        controller: 'VisualizationCtrl',
        controllerAs: 'Visualization',
        resolve: {
          initialConfig: function(){
            return {
              viewObject:0, //0 = people, 1 = groups
              viewMode:'individual-force',
              // viewMode:'all',
              ids: [10000473],
              title: 'undefined title',
              networkComplexity: '1.75',
              dateMin:1500,
              dateMax:1700,
              confidenceMin:60,
              confidenceMax:100,
              login: {
                status: true,
                user: 'Elizabeth',
              },
              contributionMode: false,
              dateTypes : ['On', 'Circa', 'Before', 'Before/On','After', 'After/On'],
              onlyMembers: false
            }
          },
          initialData: function(apiService) {
            return apiService.getFile('./data/baconnetwork.json');
          }
        }
      })
      .when('/table', {
        templateUrl: 'views/table.html',
        controller: 'TableCtrl',
        controllerAs: 'Table'
      })
      .when('/modal', {
        templateUrl: 'views/modal.html',
        controller: 'ModalCtrl',
        controllerAs: 'Modal'
      })
      .otherwise({
        redirectTo: '/visualization'
      });
  });
