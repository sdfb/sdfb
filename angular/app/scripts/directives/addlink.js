'use strict';
/**
 * @ngdoc directive
 * @name redesign2017App.directive:addLink
 * @description
 * # addLink
 */
angular.module('redesign2017App')
  .directive('addLink', ['apiService', '$timeout', '$rootScope', '$window', '$http', function(apiService, $timeout, $rootScope, $window, $http) {
    return {
      templateUrl: './views/add-link.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        scope.newLink.startDateType = scope.newLink.endDateType = scope.config.dateTypes[1];

        scope.config.relTypeCats = null;
        $http.get("/data/rel_cats.json").then(function(result){
            scope.config.relTypeCats = result.data;
            scope.newLink.relType = scope.config.relTypeCats[10];
        });

        // console.log(scope.config.relTypeCats);
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
          scope.newLink.relType = scope.config.relTypeCats[10];
          scope.newLink.confidence = scope.slider.value;
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

          scope.addedLinks.forEach(function (a,i) {
            if (a.id === newLink.id) {
              scope.addedLinks[i].source.attributes.name = newLink.source.name;
              scope.addedLinks[i].source.id = newLink.source.id;
              scope.addedLinks[i].target.attributes.name = newLink.target.name;
              scope.addedLinks[i].target.id = newLink.target.id;
              scope.addedLinks[i].weight = newLink.confidence;
              scope.addedLinks[i].start_year = newLink.startDate;
              scope.addedLinks[i].end_year = newLink.endDate;
              scope.addedLinks[i].start_year_type = newLink.startDateType;
              scope.addedLinks[i].end_year_type = newLink.endDateType;
              scope.addedLinks[i].id = newLink.id;
              scope.addedLinks[i].relType = newLink.relType;
            }
          });
          var allIDs = {};
          scope.addToDB.links.forEach(function(n) { allIDs[n.id] = true; });
          if (scope.newLink.id in allIDs) {
            scope.addToDB.links.forEach(function (a,i) {
              if (a.id === newLink.id) {
                scope.addToDB.links[i] = newLink;
                scope.addToDB.links[i].startDateType = newLink.startDateType.abbr;
                scope.addToDB.links[i].endDateType = newLink.endDateType.abbr;
                newLink.relType = newLink.relType.id.toString();
              }
            })
          } else {
            newLink.startDateType = newLink.startDateType.abbr;
            newLink.endDateType = newLink.endDateType.abbr;
            newLink.relType = newLink.relType.id.toString();
            scope.addToDB.links.push(newLink);
          }
          // newLink.startDateType = newLink.startDateType.abbr;
          // newLink.endDateType = newLink.endDateType.abbr;
          // newLink.relType = newLink.relType.id.toString();
          // scope.addToDB.links.push(newLink);
          console.log(scope.addToDB);
          scope.addLinkClosed = true;
          scope.newLink = {source: {}, target: {}};
          d3.select('#startDate').attr('placeholder', null);
          d3.select('#endDate').attr('placeholder', null);
          scope.config.added = true;
          scope.newLink.startDateType = scope.newLink.endDateType = scope.config.dateTypes[1];
          scope.newLink.relType = scope.config.relTypeCats[10];
          scope.newLink.confidence = scope.slider.value;

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
