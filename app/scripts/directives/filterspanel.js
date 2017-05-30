'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:filtersPanel
 * @description
 * # filtersPanel
 */
angular.module('redesign2017App')
  .directive('filtersPanel', function () {
    return {
      templateUrl: './views/filters-panel.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the filtersPanel directive');
      }
    };
  });
