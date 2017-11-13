'use strict';
/**
 * @ngdoc directive
 * @name redesign2017App.directive:addLink
 * @description
 * # addLink
 */
angular.module('redesign2017App')
  .directive('addLink', ['apiService', '$timeout', '$rootScope', '$window', function(apiService, $timeout, $rootScope, $window) {
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
        scope.addedLinkId = 0;
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

        scope.linkAlert = function() {
          if (scope.addLinkClosed) {
            $window.alert('To add a relationship, drag a node onto any other. If the node you need is not in this view, add it by double-clicking.');
          } else {
            scope.addLinkClosed = true;
          }
        }

        scope.showNewLink = function(d, nodes) {
          // var nodes = scope.data.included;
          nodes.forEach(function (otherNode) {
            var distance = Math.sqrt(Math.pow(otherNode.x - d3.event.x, 2) + Math.pow(otherNode.y - d3.event.y, 2));
            if (scope.config.contributionMode) {
              d3.selectAll('.node').on('mouseenter', null);
              d3.select('#l'+d.id)
                .classed('temporary-unhidden', true);
              if (otherNode != d && distance < 10) {
                otherNode.radius = true;

                d3.select("#n"+otherNode.id).transition()
                  .attr('r', 25);
                scope.newLink.source.name = d.attributes.name;
                scope.newLink.source.id = d.id;
                scope.newLink.target.name = otherNode.attributes.name;
                scope.newLink.target.id = otherNode.id;
                scope.$apply(function() {
                  scope.addLinkClosed = false;
                  scope.legendClosed = true;
                  $rootScope.filtersClosed = true;
                  scope.peopleFinderClosed = true;
                  scope.groupAssignClosed = true;
                  scope.addNodeClosed = true;
                });
                if (d.id && otherNode.id) {
                  apiService.getPeople(d.id.toString()+','+otherNode.id.toString()).then(function (result) {
                    var person1BirthYear = parseInt(result.data[0].attributes.birth_year);
                    var person1DeathYear = parseInt(result.data[0].attributes.death_year);
                    var person2BirthYear = parseInt(result.data[1].attributes.birth_year);
                    var person2DeathYear = parseInt(result.data[1].attributes.death_year);
                    $timeout(function(){
                      if (person1BirthYear >= person2BirthYear) {
                        d3.select('#startDate').attr('placeholder', person1BirthYear);
                      } else {
                        d3.select('#startDate').attr('placeholder', person2BirthYear);
                      };
                      if (person1DeathYear <= person2DeathYear) {
                        d3.select('#endDate').attr('placeholder', person1DeathYear);
                      } else {
                        d3.select('#endDate').attr('placeholder', person2DeathYear);
                      }
                    })
                  });
                }
              }
              else {
                otherNode.radius = false;
                d3.select("#n"+otherNode.id)
                  .transition().attr('r', function(d) { // Size nodes by degree of distance
                    if (scope.config.viewMode == 'shared-network') {
                      if (d.distance === 0 || d.distance === 3) {
                        return 25;
                      } else if (d.distance === 2 || d.distance == 7) {
                        return 12.5;
                      } else {
                        return 6.25;
                      }
                    } else if (scope.config.viewMode === 'group-force') {
                      if (scope.members.indexOf(d.id) === -1 && d.distance !== 7) { return 6.25; }
                      else if (scope.members.indexOf(d.id) !== -1 || d.distance == 7) { return 12.5; };
                    } else {
                      if (d.distance == 0) {
                        return 25;
                      } else if (d.distance == 1 || d.distance == 7) {
                        return 12.5;
                      } else {
                        return 6.25;
                      }
                    }
                });
              }
            }
          });
        }

        scope.createNewLink = function(d, nodes, addedLinks) {

          nodes.forEach(function (otherNode) {
            var nodeDistance = Math.sqrt(Math.pow(otherNode.x - d3.event.x, 2) + Math.pow(otherNode.y - d3.event.y, 2));
            if (otherNode != d && nodeDistance < 10) {
              console.log("new link added:", otherNode.attributes.name);
              var newLink = {id: scope.addedLinkId, source: d, target: otherNode, weight: 60, start_year: 1500, end_year: 1700, new: true};
              addedLinks.push(newLink);
              scope.$apply(function() {
                scope.legendClosed = true;
                scope.newLink.id = scope.addedLinkId;
                scope.addedLinkId += 1;
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

        scope.removeLink = function(id) {
          scope.addedLinks.forEach(function(a, i) {
            if (a.id === id) {
              scope.addedLinks.splice(i,1);
            }
          })
          scope.addToDB.links.forEach(function(a, i) {
            if (a.id === id) {
              scope.addToDB.links.splice(i,1);
            }
          })
          scope.updateNetwork(scope.data);
          scope.newLink = {source: {}, target: {}};
          scope.newLink.startDateType = scope.newLink.endDateType = scope.config.dateTypes[1];
          scope.addLinkClosed = true;

        }

        scope.submitLink = function() {
          console.log("link submitted");
          var newLink = angular.copy(scope.newLink)
          if (!newLink.startDate) {
            newLink.startDate = d3.select('#startDate').attr('placeholder');
          }
          if (!newLink.endDate) {
            newLink.endDate = d3.select('#endDate').attr('placeholder');
          }
          newLink.startDateType = newLink.startDateType.abbr;
          newLink.endDateType = newLink.endDateType.abbr;
          newLink.relType = newLink.relType.id.toString();
          newLink.created_by = scope.config.userId;
          scope.addToDB.links.push(newLink);
          console.log(scope.addToDB);
          scope.addLinkClosed = true;
          scope.newLink = {source: {}, target: {}};
          d3.select('#startDate').attr('placeholder', null);
          d3.select('#endDate').attr('placeholder', null);
          scope.config.added = true;
          scope.newLink.startDateType = scope.newLink.endDateType = scope.config.dateTypes[1];
          scope.newLink.relType = scope.config.relTypes[3];

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
