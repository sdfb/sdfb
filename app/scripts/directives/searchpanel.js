'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:searchPanel
 * @description
 * # searchPanel
 */
angular.module('redesign2017App')
  .directive('searchPanel', function () {
    return {
      templateUrl: './views/search-panel.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the searchPanel directive');
        scope.people = ['Francis Bacon (1600)', 'Francis Bacon (1587)', 'Francis Bacon (1561)','William Shakespeare', 'John Milton', 'Alice Spencer'];
      	scope.personSelected = scope.people[1];
      	scope.radioModel = 'individual-force';

        scope.groups = ['Virginia Company (1606)', 'Marian martyrs 1555', 'Cavalier poets  1640','Puritans 1532', 'Castalian band  1584', 'Participants in the vestiarian controversy  1563'];
        scope.groupSelected = scope.groups[0];
      }
    };
  });
