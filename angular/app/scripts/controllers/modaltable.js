'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalinstanceCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalTableCtrl', function($scope, $uibModalInstance, $timeout, data, viewMode, apiService) {

    var $ctrl = this;
    $ctrl.data = data;
    $ctrl.viewMode = viewMode;

    if ($ctrl.viewMode === 'individual-force' || $ctrl.viewMode === 'individual-concentric') {
      $ctrl.personData = [$ctrl.data.included[0].attributes];

      var sourceId = $ctrl.data.data.attributes.primary_people[0];

      var searchIds = [];

      $ctrl.data.data.attributes.connections.forEach(function(l) {
        if (l.attributes.source.id === sourceId) {
          searchIds.push(l.attributes.target.id);
        } else if (l.attributes.target.id === sourceId) {
          searchIds.push(l.attributes.source.id);
        }
      });
      searchIds = searchIds.join();

      apiService.getPeople(searchIds).then(function (result) {

        var all_people = result.data;
        $timeout(function(){
          $ctrl.peopleList = all_people;
        });
      });
    } else if ($ctrl.viewMode === 'shared-network') {
      $ctrl.personData = []
      $ctrl.data.included.slice(0,2).forEach( function(i) { $ctrl.personData.push(i.attributes); });
      var sources = $ctrl.data.data.attributes.primary_people[0];

      var searchIds = [];

      $ctrl.data.included.forEach(function(i) { if (sources.indexOf(i.id) === -1) { searchIds.push(i.id); } });

      searchIds = searchIds.join();

      apiService.getPeople(searchIds).then(function (result) {

        var all_people = result.data;
        $timeout(function(){
          $ctrl.peopleList = all_people;
        });
      });

    } else if ($ctrl.viewMode === 'all') {
      $ctrl.groupList = $ctrl.data.included;
    }

    $ctrl.ok = function() {
      $uibModalInstance.close($ctrl.selected.group);
    };

    $ctrl.cancel = function() {
      console.log('dismiss')
      $uibModalInstance.dismiss('cancel');
    };

  });
