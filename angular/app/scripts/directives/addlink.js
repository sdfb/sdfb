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

        scope.config.relTypeCats = null;
        $http.get("/data/rel_cats.json").then(function(result){
            scope.config.relTypeCats = result.data;
            scope.newLink.relType = scope.config.relTypeCats[10];
        });

        scope.newLink.source = {};
        scope.newLink.target = {};
        scope.addedLinkId = 0;
        scope.slider = {
          value: 60,
          options: {
            floor: 0,
            ceil: 100,
            translate: function(v) {
                return v;
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
            $window.alert('To add a relationship, drag a node onto any other. If the node you need is not in this view, add it by double-clicking. You can search within this view by clicking the magnifying glass on the right.');
          } else {
            scope.addLinkClosed = true;
          }
        }

        scope.prepopulate = function(sourceNode, targetNode) {
          scope.newLink.startDateType = scope.config.dateTypes[5];
          scope.newLink.endDateType = scope.config.dateTypes[3];
          scope.newLink.source.name = sourceNode.attributes.name;
          scope.newLink.source.id = parseInt(sourceNode.id);
          scope.newLink.target.name = targetNode.attributes.name;
          scope.newLink.target.id = parseInt(targetNode.id);
          if (sourceNode.id && targetNode.id) {
            apiService.getPeople(sourceNode.id.toString()+','+targetNode.id.toString()).then(function (result) {
              var person1BirthYear = parseInt(result.data[0].attributes.birth_year);
              var person1DeathYear = parseInt(result.data[0].attributes.death_year);
              var person2BirthYear = parseInt(result.data[1].attributes.birth_year);
              var person2DeathYear = parseInt(result.data[1].attributes.death_year);
              $timeout(function(){
                if (person1BirthYear >= person2BirthYear) {
                  scope.newLink.startDate = person1BirthYear;
                } else {
                  scope.newLink.startDate = person2BirthYear;
                };
                if (person1DeathYear <= person2DeathYear) {
                  scope.newLink.endDate = person1DeathYear;
                } else {
                  scope.newLink.endDate = person2DeathYear;
                }
              })
            });
          }
        }

        scope.showNewLink = function(d, nodes) {
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

                scope.$apply(function() {
                  scope.addLinkClosed = false;
                  $rootScope.legendClosed = true;
                  $rootScope.filtersClosed = true;
                  scope.peopleFinderClosed = true;
                  scope.groupAssignClosed = true;
                  scope.addNodeClosed = true;
                });
                scope.prepopulate(d, otherNode);

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
              console.log(scope.newLink.startDate);
              var newLink = {id: scope.addedLinkId, source: d, target: otherNode, weight: angular.copy(scope.newLink.confidence), start_year: angular.copy(scope.newLink.startDate), end_year: angular.copy(scope.newLink.endDate), start_year_type: angular.copy(scope.newLink.startDateType), end_year_type:angular.copy(scope.newLink.endDateType), new: true};
              addedLinks.push(newLink);
              scope.$apply(function() {
                $rootScope.legendClosed = true;
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
                newLink.relType = newLink.relType.id;
              }
            })
          } else {
            newLink.startDateType = newLink.startDateType.abbr;
            newLink.endDateType = newLink.endDateType.abbr;
            newLink.relType = newLink.relType.id;
            scope.addToDB.links.push(newLink);
          }
          console.log(scope.addToDB);
          scope.addLinkClosed = true;
          scope.newLink = {source: {}, target: {}};
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
