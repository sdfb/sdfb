'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:addNode
 * @description
 * # addNode
 */
angular.module('redesign2017App')
  .directive('addNode', ['apiService', '$rootScope', '$window', '$stateParams', function (apiService, $rootScope, $window, $stateParams) {
    return {
      templateUrl: './views/add-node.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the addNode directive');
        scope.newNode.birthDateType = scope.newNode.deathDateType = scope.config.dateTypes[1];

        scope.addedNodeId = 0;

        scope.nodeAlert = function() {
          if (scope.addNodeClosed) {
            $window.alert('To add a person, double-click anywhere on the canvas. To edit a new person, click on the node.');
          } else {
            scope.addNodeClosed = true;
          }
        }

        scope.$watch('noResultsPersonAdd', function(newValue, oldValue) {
          // scope.noResults = newValue;
          if (newValue) {
            scope.newNode.exists = false;
            scope.notInView = true;
          }
        });

        // When canvas is clicked, add a new circle with dummy data
        scope.addNode = function(addedNodes, point, update) {
          console.log(scope.data);

          scope.newNode.exists = false;

          var x = point[0];
          var y = point[1];

          var newNode = { attributes: { name: scope.newNode.name, degree: 1 }, id: scope.addedNodeId, order: scope.addedNodeId, distance: 7, x: x, y: y};
          newNode.vx = null;
          newNode.vy = null;
          newNode.fx = x;
          newNode.fy = y;
          newNode.absx = x;
          newNode.absy = y;
          console.log(newNode);
          addedNodes.push(newNode);
          scope.$apply(function() {
            scope.addNodeClosed = false;
            scope.legendClosed = true;
            scope.addLinkClosed = true;
            scope.groupAssignClosed = true;
            $rootScope.filtersClosed = true;
            scope.newNode.id = scope.addedNodeId;
            scope.origId = newNode.order;
            scope.addedNodeId += 1;
          });
          update(scope.data);



        }

        scope.foundPerson = function($item) {
          scope.newNode.exists = true;
          apiService.getPeople($item.id).then(function (result) {
            var person = result.data[0];
            scope.newNode.name = person.attributes.name;
            scope.newNode.birthDate = person.attributes.birth_year;
            scope.newNode.birthDateType = scope.config.dateTypes.filter(function(d) { return person.attributes.birth_year_type === d.abbr; })[0];
            scope.newNode.deathDate = person.attributes.death_year;
            scope.newNode.deathDateType = scope.config.dateTypes.filter(function(d) { return person.attributes.death_year_type === d.abbr; })[0];
            scope.newNode.historical_significance = person.attributes.historical_significance;
            scope.newNode.id = person.id;
          });
          var ids_in_view = {};
          d3.selectAll('.node').each(function(d) { ids_in_view[d.id] = true; });
          if ($item.id in ids_in_view) {
            scope.notInView = false;
            //
            // var origValue = d3.select('#n'+$item.id).attr('r');
            // d3.select('#n'+$item.id)
            //   .transition(5000).attr('r', 50)
            //   .transition(5000).attr('r', origValue);

            d3.selectAll('.label').classed('hidden', true);
            d3.select("#l"+$item.id).classed('hidden', false);//function(l) {
              // return (l.attributes.name.toLowerCase().search(scope.newNode.name.toLowerCase()) != -1) ? false : true;
            // });
          }
          else {
            scope.notInView = true;
          }
        }

        scope.removeNode = function(id) {
          console.log(id);
          scope.addedNodes.forEach(function(a, i) {
            if (a.id === id) {
              scope.addedNodes.splice(i,1);
            }
          })
          scope.addToDB.nodes.forEach(function(a, i) {
            if (a.id === id) {
              scope.addToDB.nodes.splice(i,1);
            }
          })
          scope.updateNetwork(scope.data);
          scope.newNode = {};
          scope.newNode.birthDateType = scope.newNode.deathDateType = scope.config.dateTypes[1];
          scope.addNodeClosed = true;

        }

        function checkForNameless(arr) {
          arr.forEach(function(a) {
            if (!a['name']) {
              return true;
            }
          });
        }
        scope.submitNode = function() {
          console.log("node submitted");

          if (scope.notInView === true || scope.notInView === undefined) {
            scope.addedNodes.forEach(function (a,i) {
              console.log(a.id, scope.newNode.id);
              if (a.id === scope.origId) {
                scope.addedNodes[i].attributes = scope.newNode;
                scope.addedNodes[i].id = scope.newNode.id;
              }
            });
            var allIDs = {};
            scope.addToDB.nodes.forEach(function(n) { allIDs[n.id] = true; });
            // if (!scope.newNode.exists) {
              if (scope.origId in allIDs) {
                console.log('not working');
                scope.addToDB.nodes.forEach(function (a,i) {
                  console.log(a.id, scope.newNode.id);
                  if (a.id === scope.origId) {
                    var newNode = angular.copy(scope.newNode);
                    scope.addToDB.nodes[i] = newNode;
                    scope.addToDB.nodes[i].birthDateType = newNode.birthDateType.abbr;
                    scope.addToDB.nodes[i].deathDateType = newNode.deathDateType.abbr;
                  }
                })
              } else if (!scope.newNode.exists) {
                console.log("working");
                var newNode = angular.copy(scope.newNode);
                newNode.birthDateType = newNode.birthDateType.abbr;
                newNode.deathDateType = newNode.deathDateType.abbr;
                scope.addToDB.nodes.push(newNode);
              }
            // }
            if (scope.alsoGroupAssign) {
              var newGroupAssign = angular.copy(scope.newGroupAssign);
              newGroupAssign.person = {};
              newGroupAssign.group = {};
              newGroupAssign.person.name = scope.newNode.name;
              newGroupAssign.startDateType = newGroupAssign.startDateType.abbr;
              newGroupAssign.endDateType = newGroupAssign.endDateType.abbr;
              newGroupAssign.person.id = scope.newNode.id;
              newGroupAssign.group.name = scope.groupName;
              newGroupAssign.group.id = $stateParams.ids;
              scope.addToDB.group_assignments.push(newGroupAssign);
            }

          }

          scope.updateNetwork(scope.data);

          scope.addNodeClosed = true;
          scope.newNode = {};
          scope.newGroupAssign = {};
          scope.newNode.birthDateType = scope.newNode.deathDateType = scope.config.dateTypes[1];
          console.log(scope.addToDB);
          scope.config.added = true;

        }
      }
    };
  }]);
