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
        controller: 'VisualizationCtrl',
        controllerAs: 'Visualization',
        resolve: {
          initialConfig: function(){
            return {
              viewObject:0, //0 = people, 1 = groups
              viewMode:'individual-force',
              title: 'undefined title',
              networkComplexity: '2',
              dateMin:1500,
              dateMax:1700,
              confidenceMin:60,
              confidenceMax:100,
              login: {
                status: true,
                user: 'Elizabeth',
              },
              contributionMode: false,
              dateTypes : ['On', 'Circa', 'Before', 'Before/On','After', 'After/On']
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
