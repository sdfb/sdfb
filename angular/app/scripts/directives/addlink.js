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
        scope.config.relTypes = [{'name': 'Enemy of', 'id': 1},
              {'name': 'Rival of', 'id': 2},
              {'name': 'Acquaintance of', 'id': 3},
              {'name': 'Met', 'id': 4},
              {'name': 'Knew in passing', 'id': 5},
              {'name': 'Close friend of', 'id': 6},
              {'name': 'Friend of', 'id': 7},
              {'name': 'Attracted to/Admired by', 'id': 8},
              {'name': 'Had child with', 'id': 9},
              {'name': 'Sexual partner of', 'id': 10},
              {'name': 'Pupil/Student of-Mentor/Teacher of', 'id': 11},
              {'name': 'Mentor/Teacher of-Pupil/Student of', 'id': 12},
              {'name': 'Aunt/Uncle of-Niece/Nephew of', 'id': 13},
              {'name': 'Cousin of', 'id': 14},
              {'name': 'Child-in-law of/Parent-in-law of', 'id': 16},
              {'name': 'Guardian of/Ward of', 'id': 17},
              {'name': 'Heir(ess) of/Testator to', 'id': 18},
              {'name': 'Other-in-law of/Other-in-law of', 'id': 19},
              {'name': 'Sibling-in-law of', 'id': 21},
              {'name': 'Great-grandparent of/Great-grandchild of', 'id': 24},
              {'name': 'Child of/Parent of', 'id': 25},
              {'name': 'Grandchild of/Grandparent of', 'id': 27},
              {'name': 'Sibling of', 'id': 30},
              {'name': 'Godchild of/Godparent of', 'id': 31},
              {'name': 'Godsibling of', 'id': 33},
              {'name': 'Client of/Patron of', 'id': 34},
              {'name': 'Collaborated with', 'id': 35},
              {'name': 'Colleague of', 'id': 36},
              {'name': 'Coworker of', 'id': 37},
              {'name': 'Apprentice of/Master of', 'id': 39},
              {'name': 'Employed by/Employer of', 'id': 40},
              {'name': 'Rented from/Rented to', 'id': 43},
              {'name': 'Engaged to', 'id': 45},
              {'name': 'Spouse of', 'id': 46},
              {'name': 'Parishoner of/Priest of', 'id': 47},
              {'name': 'Other religious relationship', 'id': 49},
              {'name': 'Lived with', 'id': 50},
              {'name': 'Neighbor of', 'id': 51},
              {'name': 'Step-parent of/Step-child of', 'id': 103},
              {'name': 'Step-sibling of', 'id': 105},
              {'name': 'Creditor of/Debtor of', 'id': 106},
              {'name': 'Schoolmate of', 'id': 108},
              {'name': 'Correspondent of', 'id': 109},
              {'name': 'Midwife for/Had as midwife', 'id': 110},
              {'name': 'Attendant of/Attended by', 'id': 112}]
        scope.newLink.relType = scope.config.relTypes[3];
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
                  scope.legendClosed = true;
                  scope.filtersClosed = true;
                  scope.peopleFinderClosed = true;
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
