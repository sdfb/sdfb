'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:searchPanel
 * @description
 * # searchPanel
 */
angular.module('redesign2017App')
  .directive('searchPanel', ['$state', 'apiService', function($state, apiService) {
    return {
      templateUrl: './views/search-panel.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the searchPanel directive');
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
          scope.config.person1 = $person1.id
          $state.go('home.visualization', {ids: $person1.id});
        };

        scope.selectedShared = function($person2) {
          var ids = [scope.config.person1, $person2.id].join()
          $state.go('home.visualization', {ids: ids});
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
          $state.go('home.visualization', {ids: $item.id});
        }

      }
    };
  }]);
