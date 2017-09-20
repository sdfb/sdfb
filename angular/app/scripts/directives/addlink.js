'use strict';
/**
 * @ngdoc directive
 * @name redesign2017App.directive:addLink
 * @description
 * # addLink
 */
angular.module('redesign2017App')
  .directive('addLink', ['apiService', '$timeout', function(apiService, $timeout) {
    return {
      templateUrl: './views/add-link.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        scope.newLink.startDateType = scope.newLink.endDateType = scope.config.dateTypes[1];
        scope.newLink.source = {};
        scope.newLink.target = {};
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
        scope.newLink.confidence = scope.slider.value;
        scope.refreshSlider = function() {
          $timeout(function() {
          	console.log('refresh');
            scope.$broadcast('rzSliderForceRender');
          }, 500);
        };

        scope.showNewLink = function(d) {
          var nodes = scope.data.included;
          nodes.forEach(function (otherNode) {
            var distance = Math.sqrt(Math.pow(otherNode.x - d3.event.x, 2) + Math.pow(otherNode.y - d3.event.y, 2));
            if (scope.config.contributionMode) {
              d3.selectAll('.node').on('mouseenter', null);
              d3.select('#l'+d.id)
                .classed('temporary-unhidden', true);
              if (otherNode != d && distance < 10) {
                otherNode.radius = true;

                d3.select("#n"+otherNode.id).transition()
                  .attr('r', 25)
                  .attr('stroke', 'orange')
                  .attr('stroke-dasharray', 5,5);
                scope.newLink.source.name = d.attributes.name;
                scope.newLink.source.id = d.id;
                scope.newLink.target.name = otherNode.attributes.name;
                scope.newLink.target.id = otherNode.id;
                scope.$apply(function() {
                  scope.addLinkClosed = false;
                });

              }
              else {
                otherNode.radius = false;
                d3.select("#n"+otherNode.id)
                  .transition().attr('r', function(d) { // Size nodes by degree of distance
                  if (d.distance == 0) {
                    return 25;
                  } else if (d.distance == 1) {
                    return 12.5;
                  } else {
                    return 6.25;
                  }
                })
                .attr('stroke-dasharray', null);
              }
            }
          });
        }

        scope.createNewLink = function(d, nodes, addedLinks) {

          nodes.forEach(function (otherNode) {
            var nodeDistance = Math.sqrt(Math.pow(otherNode.x - d3.event.x, 2) + Math.pow(otherNode.y - d3.event.y, 2));
            if (otherNode != d && nodeDistance < 10) {
              console.log("new link added:", otherNode.attributes.name);
              var newLink = {source: d, target: otherNode, weight: 100, start_year: 1500, end_year: 1700, new: true};
              addedLinks.push(newLink);
              scope.$apply(function() {
                scope.legendClosed = true;
              });
            }
          });
          d3.selectAll(".node").attr('r', function(d) { // Size nodes by degree of distance
            if (d.distance == 0) {
              return 25;
            } else if (d.distance == 1) {
              return 12.5;
            } else {
              return 6.25;
            }
          });
        }

        // Functions for adding links with Typeahead, do we want to allow this?
        // scope.foundSourcePerson = function($item) {
        //   scope.newNode.exists = true;
        //   apiService.getPeople($item.id).then(function (result) {
        //     var person = result.data[0];
        //     scope.newLink.source.name = person.attributes.name;
        //     scope.newLink.source.id = $item.id;
        //   });
        // }
        //
        // function checkForLink(arr) {
        //   arr.forEach(function(l) {
        //     if (l.source === scope.newLink.source.id || l.source === scope.newLink.target.id) {
        //       if (l.target === scope.newLink.source.id || l.target === scope.newLink.target.id) {
        //         return true;
        //       }
        //     }
        //   })
        // }
        //
        // scope.foundTargetPerson = function($item) {
        //   scope.newNode.exists = true;
        //   apiService.getPeople($item.id).then(function (result) {
        //     var person = result.data[0];
        //     scope.newLink.target.name = person.attributes.name;
        //     scope.newLink.target.id = $item.id;
        //   });
        //
        //   if (scope.config.viewMode === 'individual-force' || scope.config.viewMode === 'individual-concentric') {
        //     if (!checkForLink(scope.addedLinks)) {
        //       var newSource = angular.copy(scope.newLink.source.id);
        //       var newTarget = angular.copy(scope.newLink.target.id)
        //       var newLink = {source: newSource, target: newTarget, weight: 100, start_year: 1500, end_year: 1700, new: true};
        //       scope.addedLinks.push(newLink);
        //       scope.updatePersonNetwork(scope.data);
        //     }
        //   } else if (scope.config.viewMode === 'shared-network') {
        //     if (!checkForLink(scope.addedSharedLinks)) {
        //       var newSource = angular.copy(scope.newLink.source.id);
        //       var newTarget = angular.copy(scope.newLink.target.id)
        //       var newLink = {source: newSource, target: newTarget, weight: 100, start_year: 1500, end_year: 1700, new: true};
        //       scope.addedSharedLinks.push(newLink);
        //       scope.updateSharedNetwork(scope.data);
        //     }
        //   } else if (scope.config.viewMode === 'group-force') {
        //     if (!checkForLink(scope.addedGroupLinks)) {
        //       var newSource = angular.copy(scope.newLink.source.id);
        //       var newTarget = angular.copy(scope.newLink.target.id)
        //       var newLink = {source: newSource, target: newTarget, weight: 100, start_year: 1500, end_year: 1700, new: true};
        //       scope.addedGroupLinks.push(newLink);
        //       scope.updateGroupNetwork(scope.data);
        //     }
        //   }
        // }

        scope.submitLink = function() {
          console.log("link submitted");
          var newLink = angular.copy(scope.newLink)
          scope.addToDB.links.push(newLink);
          console.log(scope.addToDB);
          scope.addLinkClosed = true;

        }

        scope.$on('selectionUpdated', function(event, args) {
          if (scope.config.contributionMode && args.type === 'relationship') {
            console.log(args);
            scope.newLink.source.name = args.source.attributes.name;
            scope.newLink.source.id = args.source.id;
            scope.newLink.target.name = args.target.attributes.name;
            scope.newLink.target.id = args.target.id;
            // d3.select('#startDate').property('value', Math.max(source.attributes.birth_year, target.attributes.birth_year));
            // d3.select('#startDateType').property('value', 'After/On');
            // d3.select("#endDate").property('value', Math.min(source.attributes.death_year, target.attributes.death_year));
            // d3.select("#endDateType").property('value', 'Before/On');
            // d3.select('#relType').property('value', 'has met');
            scope.addLinkClosed = false;
          }
        })

        scope.$watch('addLinkClosed', function(newVal, oldVal) {
          if (newVal != oldVal) {
            console.log(newVal);
            scope.refreshSlider();
          }
        })
      }
    };
  }]);
