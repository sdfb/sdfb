'use strict';
/**
 * @ngdoc directive
 * @name redesign2017App.directive:addLink
 * @description
 * # addLink
 */
angular.module('redesign2017App')
  .directive('addLink', function($timeout) {
    return {
      templateUrl: './views/add-link.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        scope.selectedStartDateType = scope.selectedEndDateType = scope.config.dateTypes[1];
        scope.slider = {
          value: 4,
          options: {
            showTicksValues: true,
            stepsArray: [
              { value: 0, legend: 'Impossible' },
              { value: 2 },
              { value: 4 },
              { value: 6, legend: 'Possible' },
              { value: 8, legend: 'Likely' },
              { value: 100, legend: 'Sure' },
            ]
          }
        };
        scope.refreshSlider = function() {
          $timeout(function() {
          	console.log('refresh');
            scope.$broadcast('rzSliderForceRender');
          }, 500);
        };
        scope.$watch('addLinkClosed', function(newVal, oldVal) {
          if (newVal != oldVal) {
            console.log(newVal);
            scope.refreshSlider();
          }
        })
      }
    };
  });
