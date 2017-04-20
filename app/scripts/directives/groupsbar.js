'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:groupsBar
 * @description
 * # groupsBar
 */
angular.module('redesign2017App')
  .directive('groupsBar', function () {
    return {
      template: '<div></div>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        element.text('this is the groupsBar directive');
      }
    };
  });
