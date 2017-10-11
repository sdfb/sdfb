'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:addNode
 * @description
 * # addNode
 */
angular.module('redesign2017App')
  .directive('groupAssign', ['apiService', '$timeout', function (apiService, $timeout) {
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

        scope.showGroupAssign = function(d) {
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

        scope.endGroupEvents = function() {
          d3.selectAll(".group").on("mouseenter", null);
          d3.selectAll(".group").on("mouseleave", null);
        }

        scope.submitGroupAssign = function() {
          console.log("node submitted");
          // var newNode = {attributes: {name: scope.person.added, birthdate: d3.select('#birthDate').node().value, deathdate: d3.select('#deathDate').node().value, title: d3.select('#title').node().value, suffix: d3.select('#suffix').node().value, alternate_names: d3.select('#alternates').node().value},  notes: d3.select('#alternates').node().value, id: addedNodeID}
          var newGroupAssign = angular.copy(scope.groupAssign);
          scope.addToDB.group_assignments.push(newGroupAssign);
          console.log(scope.addToDB);

          scope.dragNodes.forEach(function(d) {
            if (d.distance === 7 && d.id === scope.groupAssign.person.id) {
              d.x = scope.singleWidth/2;
              d.y = scope.singleHeight/2;
              d.vx = null;
              d.vy = null;
            }
          });
          d3.select('.g'+scope.groupAssign.group.id).classed('active', false);
          scope.groupAssignClosed = true;
          scope.updateNetwork(scope.data);

        }

        scope.populateGroupDates = function(personId, groupId) {
          apiService.getPeople(personId).then(function (result) {
            var personBirthYear = parseInt(result.data[0].attributes.birth_year);
            var personDeathYear = parseInt(result.data[0].attributes.death_year);
            $timeout(function(){
              apiService.getGroups(groupId).then(function (result) {
                var groupStartYear = result.data[0].attributes.start_year;
                var groupEndYear = result.data[0].attributes.end_year;
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
