'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:concentricLayout
 * @description
 * # concentricLayout
 */
angular.module('redesign2017App')
  .directive('concentricLayout', function () {
    return {
      template: '<div></div>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        element.text('this is the concentricLayout directive');
      }
    };
  });
