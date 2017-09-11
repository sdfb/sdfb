'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:searchPanel
 * @description
 * # searchPanel
 */
angular.module('redesign2017App')
  .directive('searchPanel', ['$location', 'apiService', "$route", '$routeParams', function($location, apiService, $route, $routeParams) {
    return {
      templateUrl: './views/search-panel.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the searchPanel directive');
        scope.peopleToSelect = ['Francis Bacon (1600)', 'Francis Bacon (1587)', 'Francis Bacon (1561)', 'William Shakespeare (1564)', 'John Milton (1562)', 'Alice Spencer (1559)'];
        scope.person = { 'selected': scope.peopleToSelect[1] }
        scope.radioModel = 'individual-force';

        scope.sharedToSelect = scope.peopleToSelect;
        scope.shared = { 'selected': undefined }

        scope.resetIndividualNetwork = function() {
          console.log('resetIndividualNetwork');
          scope.person.selected = undefined;
        }

        scope.resetSharedNetwork = function() {
          console.log('resetSharedNetwork');
          scope.shared.selected = undefined;
          scope.config.viewMode = 'individual-force';
        }

        scope.selectedPerson = function($person1) {
          // Manually inserted IDS since people typeahead API is not ready yet.

          //William Fleetwood + Sir Henry Yelverton
          // var ids = [10004371, 10013232];
          // shakespeare + milton
          // var ids = '10010937';

          // Sir Thomas Fanshawe + Sir Edwin Sandys
          // ids = [10004129,10010685];
          $location.search('ids', $person1.id);
          var lastRoute = $route.current;
          scope.$on('$locationChangeSuccess', function(event) {
            $route.current = lastRoute;
          });
          scope.config.viewMode = 'individual-force';
          scope.config.person1 = $person1.id
          scope.config.ids = $person1.id;
        };

        scope.selectedShared = function($person2) {
          // Manually inserted IDS since people typeahead API is not ready yet.

          //William Fleetwood + Sir Henry Yelverton
          // var ids = [10004371, 10013232];
          // shakespeare + milton
          var ids = [scope.config.person1, $person2.id];
          $location.search('ids', ids);
          var lastRoute = $route.current;
          scope.$on('$locationChangeSuccess', function(event) {
            $route.current = lastRoute;
          });
          scope.config.viewMode = 'shared-network';
          scope.config.ids = ids;
          // $route.updateParams({people: ids.toString()});
          // $location.search('ids', ids.toString());
          // Sir Thomas Fanshawe + Sir Edwin Sandys
          // ids = [10004129,10010685];
          // if (ids.length == 2) {
          //   console.log('Calling shared network...')
          //   apiService.getNetwork(ids).then(function(result) {
          //     console.log('shared network between',ids.toString(),'\n',result);
          //     scope.config.viewMode = 'shared-network';
          //     scope.$broadcast('shared network query', result);
          //   })
          // }
        };

        scope.groupTypeahead = { 'selected': undefined }

        scope.callGroupsTypeahead = function(val) {
          console.log(val)
          return apiService.groupsTypeahead(val);
        };

        scope.callPersonTypeahead = function(val) {
          console.log(val)
          return apiService.personTypeahead(val);
        };

        scope.groupSelected = function($item, $model, $label, $event) {
          console.log($item.name, $item.id, 'getting group network...');
          $location.search('ids', $item.id);
          var lastRoute = $route.current;
          scope.$on('$locationChangeSuccess', function(event) {
            $route.current = lastRoute;
          });
          scope.config.viewMode = 'group-force';
          scope.config.ids = $item.id;
          scope.config.title = $item.name;
        }


        // scope.groupsTypeahead = ['Virginia Company (1606)', 'Marian martyrs 1555', 'Cavalier poets  1640', 'Puritans 1532', 'Castalian band  1584', 'Participants in the vestiarian controversy  1563'];
        // scope.groupTypeaheadSelected = scope.groupsTypeahead[0];

      }
    };
  }]);
