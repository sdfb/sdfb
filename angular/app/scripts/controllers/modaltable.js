'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalinstanceCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalTableCtrl', function($scope, $uibModalInstance, data, selectedPerson) {

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
    $ctrl.selectedPerson = selectedPerson;
    $ctrl.personData = $ctrl.data.included[0].attributes;
    // console.log($ctrl.data);

    var sourceId = $ctrl.data.data.attributes.primary_people[0]

    $ctrl.one_degree_nodes = []

    $ctrl.data.data.attributes.connections.forEach(function(l) {
      if (l.attributes.source.id === sourceId) {
        l.attributes.target.attributes.id = l.attributes.target.id;
        $ctrl.one_degree_nodes.push(l.attributes.target.attributes);
      } else if (l.attributes.target.id === sourceId) {
        l.attributes.source.attributes.id = l.attributes.source.id;
        $ctrl.one_degree_nodes.push(l.attributes.source.attributes);
      }
    });

    // console.log($ctrl.one_degree_nodes);
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
