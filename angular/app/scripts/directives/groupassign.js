'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:addNode
 * @description
 * # addNode
 */
angular.module('redesign2017App')
  .directive('groupAssign', ['apiService', '$timeout', '$window', function (apiService, $timeout, $window) {
    return {
      templateUrl: './views/group-assign.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the groupAssign directive');
				scope.groupAssign.startDateType = scope.config.dateTypes[5];
        scope.groupAssign.endDateType = scope.config.dateTypes[3];

        scope.groupAssignSelected = function($item, $model, $label, $event) {
          scope.groupAssign.group = $item;
          scope.populateGroupDates(scope.groupAssign.person.id, $item.id);
        }

        scope.groupAssignAlert = function() {
          if (scope.groupAssignClosed) {
            $window.alert('To add a person to a group, drag any node to the groups bar.');
          } else {
            scope.groupAssignClosed = true;
          }
        }

        scope.showGroupAssign = function(d) {
          if (scope.config.contributionMode) {
            d3.selectAll(".group").on('mouseenter', function(g) {
              d3.select(this).classed('active', true);
              scope.$apply(function() {
                scope.groupAssign.person.name = d.attributes.name;
                scope.groupAssign.person.id = d.id;
                scope.groupAssign.group.name = g.name;
                scope.groupAssign.group.id = g.groupId;
                scope.groupAssignClosed = false;
                scope.addLinkClosed = true;
                scope.legendClosed = true;
                scope.filtersClosed = true;
                scope.peopleFinderClosed = true;
                scope.populateGroupDates(d.id, g.groupId);
              });
            })
            .on('mouseleave', function(g) {
              scope.$apply(function() {
                scope.groupAssignClosed = true;
              });
              d3.select(this).classed('active', false);
            });
          }
        }

        scope.endGroupEvents = function() {
          d3.selectAll(".group").on('mouseenter', function(d, i) {
            if (!scope.groupsToggle) {
              if (i < 20) {
                d3.selectAll('.link').classed('not-in-group', true);
                // assign class in-group or not-in-group to labels and to nodes
                d3.selectAll('g.label, .node').each(function(n) {
                  var className = 'not-in-group';
                  if (n.attributes.groups) {
                    var inGroup = n.attributes.groups.filter(function(e) {
                      return e == d.groupId;
                    })
                    if (inGroup.length) {
                      className = 'in-group';
                      // hide or display groups depending on group membership of source and target
                      d3.selectAll('.link').filter(function(f) {
                        var linkClassName = 'not-in-group';
                        if (f.source.attributes.groups && f.target.attributes.groups) {
                          var sourceInGroup = inGroup.some(function (e) {
                            return f.source.attributes.groups.indexOf(e) != -1 });
                          var targetInGroup = inGroup.some(function(e) {
                            return f.target.attributes.groups.indexOf(e) != -1 });
                          if (sourceInGroup && targetInGroup) {
                            linkClassName = 'in-group';
                          }
                          d3.select(this).classed(linkClassName, true);
                        }
                      })
                    }
                  }
                  d3.select(this).classed(className, true);
                })
                d3.selectAll('.link').classed('not-in-group', true);
              } else {
                d3.selectAll('g.label, .node').each(function(n) {
                  var className = 'not-in-group';
                  if (n.attributes.groups) {
                    var inGroup = _.intersectionWith(scope.groups.otherGroups, n.attributes.groups, function(a, b) {
                      return a.groupId == b;
                    });
                    if (inGroup.length) {
                      className = 'in-group'
                        // hide or display groups depending on group membership of source and target
                      d3.selectAll('.link').filter(function(f) {
                        var linkClassName = 'not-in-group';
                        if (f.source.attributes.groups && f.target.attributes.groups) {
                          var sourceInGroup = inGroup.some(function(e) {
                            return f.source.attributes.groups.indexOf(e) != -1 });
                          var targetInGroup = inGroup.some(function(e) {
                            return f.target.attributes.groups.indexOf(e) != -1 });
                          if (sourceInGroup && targetInGroup) {
                            linkClassName = 'in-group';
                          }
                          d3.select(this).classed(linkClassName, true);
                        }
                      })
                    }
                  }
                  d3.select(this).classed(className, true);
                })
                d3.selectAll('.link').classed('not-in-group', true);
              }
            }
          })
          .on('mouseleave', function(d) {
            if (!scope.groupsToggle) {
              d3.selectAll('.node, .label, .link').classed('not-in-group', false);
              d3.selectAll('.node, .label, .link').classed('in-group', false);
            }
          });
        }

        scope.submitGroupAssign = function() {
          console.log("node submitted");
          // var newNode = {attributes: {name: scope.person.added, birthdate: d3.select('#birthDate').node().value, deathdate: d3.select('#deathDate').node().value, title: d3.select('#title').node().value, suffix: d3.select('#suffix').node().value, alternate_names: d3.select('#alternates').node().value},  notes: d3.select('#alternates').node().value, id: addedNodeID}
          var newGroupAssign = angular.copy(scope.groupAssign);
          newGroupAssign.startDateType = newGroupAssign.startDateType.abbr;
          newGroupAssign.endDateType = newGroupAssign.endDateType.abbr;
          // newGroupAssign.created_by = scope.config.userId;
          scope.addToDB.group_assignments.push(newGroupAssign);
          console.log(scope.addToDB);

          scope.dragNodes.forEach(function(d) {
            if (d.distance === 7 && d.id === scope.groupAssign.person.id) {
              d.x = d.absx;
              d.y = d.absy;
              d.fx = d.absx;
              d.fy = d.absy;
              d.vx = null;
              d.vy = null;
            }
          });
          d3.select('.g'+scope.groupAssign.group.id).classed('active', false);
          scope.groupAssignClosed = true;
          scope.updateNetwork(scope.data);
          scope.config.added = true;

        }

        scope.populateGroupDates = function(personId, groupId) {
          apiService.getPeople(personId).then(function (result) {
            var personBirthYear = parseInt(result.data[0].attributes.birth_year);
            var personDeathYear = parseInt(result.data[0].attributes.death_year);
            $timeout(function(){
              apiService.getGroups(groupId).then(function (result) {
                var groupStartYear = result.data.data[0].attributes.start_year;
                var groupEndYear = result.data.data[0].attributes.end_year;
                $timeout(function(){
                  if (personBirthYear >= groupStartYear) {
                    scope.groupAssign.startDate = personBirthYear;
                  } else {
                    scope.groupAssign.startDate = groupStartYear;
                  };
                  if (personDeathYear <= groupEndYear) {
                    scope.groupAssign.endDate = personDeathYear;
                  } else {
                    scope.groupAssign.endDate = groupEndYear;
                  }
                });
              });
            });
          });
        }
      }
    };
  }]);
