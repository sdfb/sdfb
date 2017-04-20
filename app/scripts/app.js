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
    'ui.bootstrap'
  ])
  .config(function ($routeProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'views/main.html',
        controller: 'MainCtrl',
        controllerAs: 'main'
      })
      .when('/visualization', {
        templateUrl: 'views/visualization.html',
        controller: 'VisualizationCtrl',
        controllerAs: 'Visualization',
        resolve: {
          initialConfig: function(){
            return {
              viewObject:0, //0 = people, 1 = groups
              viewMode:'force',
              networkComplexity: 2,
              dateMin:1500,
              dateMax:1700,
              confidenceMin:60,
              confidenceMax:100,
              selectionType: undefined,
              selectionId: undefined
            }
          },
          initialData: function(apiService) {
            return apiService.getFile('./data/baconnetwork.json')
          }
        }
      })
      .when('/table', {
        templateUrl: 'views/table.html',
        controller: 'TableCtrl',
        controllerAs: 'Table'
      })
      .otherwise({
        redirectTo: '/'
      });
  });
