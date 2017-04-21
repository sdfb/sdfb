'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:contextualInfoPanel
 * @description
 * # contextualInfoPanel
 */
angular.module('redesign2017App')
  .directive('contextualInfoPanel', function () {
    return {
      templateUrl: './views/contextual-info-panel.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the contextualInfoPanel directive');
        // console.log(scope.currentSelection)

      }
    };
  });
