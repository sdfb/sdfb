'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:addNode
 * @description
 * # addNode
 */
angular.module('redesign2017App')
  .directive('addNode', ['apiService', function (apiService) {
    return {
      templateUrl: './views/add-node.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the addNode directive');
        scope.newNode.birthDateType = scope.newNode.deathDateType = scope.config.dateTypes[1];

        scope.watch('noResultsPersonAdd', function(newValue, oldValue) {
          // scope.noResults = newValue;
          if (newValue) {
            scope.newNode.exists = false;
            scope.notInView = true;
          }
        });

        // When canvas is clicked, add a new circle with dummy data
        scope.addNode = function(addedNodes, point, update) {
          scope.newNode.exists = false;

          var newNode = { attributes: { name: scope.newNode.name, degree: 1 }, id: 0, distance: 7, x: point[0], y: point[1]};
          console.log(newNode);
          addedNodes.push(newNode);
          scope.$apply(function() {
            scope.addNodeClosed = false;
            scope.legendClosed = true;
          });

          if (scope.config.viewMode === 'group-force') {
            update(scope.data, scope.data.onlyMembers);
          }
          else { update(scope.data); }



        }

        scope.foundPerson = function($item) {
          scope.newNode.exists = true;
          apiService.getPeople($item.id).then(function (result) {
            var person = result.data[0];
            scope.newNode.name = person.attributes.name;
            scope.newNode.birthDate = person.attributes.birth_year;
            scope.newNode.birthDateType = person.attributes.birth_year_type;
            scope.newNode.deathDate = person.attributes.death_year;
            scope.newNode.deathDateType = person.attributes.death_year_type;
            scope.newNode.historical_significance = person.attributes.historical_significance;
          });
          var ids_in_view = {};
          d3.selectAll('.node').each(function(d) { ids_in_view[d.id] = true; });
          if ($item.id in ids_in_view) {
            var origValue = d3.select('#n'+$item.id).attr('r');
            d3.select('#n'+$item.id)
              .transition(5000).attr('r', 50)
              .transition(5000).attr('r', origValue);
          }
          else {
            scope.notInView = true;
          }
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
          var newNode = angular.copy(scope.newNode);

          if (scope.config.viewMode === 'individual-force' ||  scope.config.viewMode === 'individual-concentric') {
            if (scope.notInView === true && scope.addedNodes.length > 0 && !scope.addedNodes[scope.addedNodes.length-1].attributes.name) {
              scope.addedNodes[scope.addedNodes.length-1].attributes.name = newNode.name;
            }
            else if (scope.notInView === true && (scope.addedNodes.length === 0 || !checkForNameless(scope.addedNodes))) {
              var newNode = { attributes: { name: scope.newNode.name, degree: 1 }, id: 0, distance: 7, x: scope.singleWidth/2, y: scope.singleHeight/2};
              scope.addedNodes.push(newNode);
            }
            scope.updatePersonNetwork(scope.data);
          } else if (scope.config.viewMode === 'shared-network') {
            if (scope.addedSharedNodes.length > 0 && !scope.addedSharedNodes[scope.addedSharedNodes.length-1].attributes.name) {
              scope.addedSharedNodes[scope.addedSharedNodes.length-1].attributes.name = newNode.name;
            }
            else if (scope.notInView === true && (scope.addedSharedNodes.length === 0 || !checkForNameless(scope.addedSharedNodes))) {
              var newNode = { attributes: { name: scope.newNode.name, degree: 1 }, id: 0, distance: 7, x: scope.singleWidth/2, y: scope.singleHeight/2};
              scope.addedSharedNodes.push(newNode);
            }
            scope.updateSharedNetwork(scope.data);
          } else if (scope.config.viewMode === 'group-force') {
            if (scope.addedGroupNodes.length > 0 && !scope.addedGroupNodes[scope.addedGroupNodes.length-1].attributes.name) {
              scope.addedGroupNodes[scope.addedGroupNodes.length-1].attributes.name = newNode.name;
            }
            else if (scope.notInView === true && (scope.addedGroupNodes.length === 0 || !checkForNameless(scope.addedGroupNodes))) {
              var newNode = { attributes: { name: scope.newNode.name, degree: 1 }, id: 0, distance: 7, x: scope.singleWidth/2, y: scope.singleHeight/2};
              scope.addedGroupNodes.push(newNode);
            }
            scope.updateGroupNetwork(scope.data, scope.data.onlyMembers);
          }

          if (scope.notInView === true)

          if (!scope.newNode.exists) { scope.addToDB.nodes.push(newNode); }
          scope.addNodeClosed = true;
          scope.newNode = {};
          console.log(scope.addToDB);

        }

        // scope.$on('selectionUpdated', function(event, args) {
        //   if (scope.config.contributionMode && args.type === 'person') {
        //     console.log(args);
        //     scope.newNode.name = args.attributes.name;
        //     scope.newNode.birthDate = args.attributes.birth_year;
        //     scope.newNode.birthDateType = args.attributes.birth_year_type;
        //     scope.newNode.deathDate = args.attributes.death_year;
        //     scope.newNode.deathDateType = args.attributes.death_year_type;
        //     scope.newNode.historical_significance = args.attributes.historical_significance;
        //     scope.newNode.exists = true;
        //     scope.addNodeClosed = false;
        //   }
        // });
      }
    };
  }]);
