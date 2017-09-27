'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalinstanceCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalTableCtrl', function($scope, $uibModalInstance, data, selectedPerson, viewMode, groupSelected) {

    // console.log('currentSelection', currentSelection);
    // console.log('groups', groups);
    //
    // if (currentSelection.attributes) {
    //   currentSelection.attributes.groups.forEach(function(selectedGroup) {
    //     // console.log(selectedGroup);
    //     groups.forEach(function(group) {
    //       // console.log(group);
    //       if (selectedGroup == group.groupId) {
    //         group.active = true;
    //       }
    //     })
    //   });
    // }
    //
    var $ctrl = this;
    $ctrl.data = data;
    // console.log($ctrl.data);
    $ctrl.selectedPerson = selectedPerson;
    $ctrl.groupSelected = groupSelected;
    $ctrl.viewMode = viewMode;

    if ($ctrl.viewMode === 'individual-force' || $ctrl.viewMode === 'individual-concentric') {
      $ctrl.personData = [$ctrl.data.included[0].attributes];

      var sourceId = $ctrl.data.data.attributes.primary_people[0];

      $ctrl.peopleList = [];

      $ctrl.data.data.attributes.connections.forEach(function(l) {
        if (l.attributes.source.id === sourceId) {
          l.attributes.target.attributes.id = l.attributes.target.id;
          $ctrl.peopleList.push(l.attributes.target.attributes);
        } else if (l.attributes.target.id === sourceId) {
          l.attributes.source.attributes.id = l.attributes.source.id;
          $ctrl.peopleList.push(l.attributes.source.attributes);
        }
      });
    } else if ($ctrl.viewMode === 'shared-network') {
      $ctrl.personData = []
      $ctrl.data.included.slice(0,2).forEach( function(i) { $ctrl.personData.push(i.attributes); });
      var sources = $ctrl.data.data.attributes.primary_people[0];

      $ctrl.peopleList = [];

      $ctrl.data.included.forEach(function(i) {
        if (sources.indexOf(i.id) === -1) {
          i.attributes.id = i.id;
          $ctrl.peopleList.push(i.attributes);
        }
      });

    } else if ($ctrl.viewMode === 'all') {
      $ctrl.groupList = $ctrl.data.included;
    }

    // console.log($ctrl.peopleList);
    //
    // // Pre-selection
    // $ctrl.selected = {
    //   group: $ctrl.groups[0]
    // };

    $ctrl.ok = function() {
      $uibModalInstance.close($ctrl.selected.group);
    };

    $ctrl.cancel = function() {
      console.log('dismiss')
      $uibModalInstance.dismiss('cancel');
    };

  });
