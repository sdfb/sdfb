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
          value: 60,
          options: {
            // showTicksValues: true,
            floor: 0,
            ceil: 100,
            // step: 20,
            // hideLimitLabels: true,
            // hidePointerLabels: true,
            // showTicks: true,
            // stepsArray: [
            //   { value: 0, legend: 'Impossible' },
            //   { value: 20, legend: 'Highly improbable'  },
            //   { value: 40, legend: 'Improbable'  },
            //   { value: 60, legend: 'Possible' },
            //   { value: 80, legend: 'Likely' },
            //   { value: 100, legend: 'Sure' },
            // ],
            translate: function(v) {
                return v;
                // switch (v) {
                //     case 0:
                //     return 'Highly improbable';
                //     // case 20:
                //     // return 'Highly improbable';
                //     // case 40:
                //     // return 'Improbable';
                //     // case 60:
                //     // return 'Possible';
                //     // case 80:
                //     // return 'Likely';
                //     case 100:
                //     return 'Certain';
                //     default:
                //     return 'mmm';
                // }
            }
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
