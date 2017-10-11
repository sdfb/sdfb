'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:VisualizationCtrl
 * @description
 * # VisualizationCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App').component('visualization', {
  bindings: { networkData: '<' },
  templateUrl: 'views/visualization.html',
  controller: ['$scope', '$uibModal', '$http', '$log', '$document', '$location', '$window', 'apiService', '$stateParams', '$transitions', function($scope, $uibModal, $http, $log, $document, $location, $window, apiService, $stateParams, $transitions) {
    // console.log(this);
    var initialConfig = {
          viewObject:0, //0 = people, 1 = groups
          viewMode:'individual-force',
          // viewMode:'all',
          ids: 10000473,
          title: 'undefined title',
          networkComplexity: '2',
          dateMin:1500,
          dateMax:1700,
          confidenceMin:60,
          confidenceMax:100,
          login: {
            status: true,
            user: 'Elizabeth',
          },
          contributionMode: $scope.$parent.config.contributionMode,
          dateTypes : ['IN', 'CIRCA', 'BEFORE', 'BEFORE/IN','AFTER', 'AFTER/IN'],
          onlyMembers: false
        }
    // console.log(initialConfig,initialData);
    $scope.config = initialConfig;
    // $scope.data = initialData;
    $scope.legendClosed = false;
    $scope.filtersClosed = true;
    $scope.peopleFinderClosed = true;
    $scope.addNodeClosed = true;
    $scope.addLinkClosed = true;
    $scope.groupAssignClosed = true;
    $scope.addGroupClosed = true;
    $scope.addToDB = {nodes: [], links: [], groups: [], group_assignments: []};
    $scope.newNode = {};
    $scope.newLink = {};
    $scope.newGroup = {};
    $scope.groupAssign = {person: {}, group: {}};

    $scope.$watch('$parent.config.contributionMode', function(newValue, oldValue) {
      $scope.config.contributionMode = newValue;
    });

    this.$onChanges = function() {
      $scope.data = this.networkData;
      if ($stateParams.type === 'all-groups') {
        $scope.config.viewMode = 'all';
        $scope.networkName = "Co-membership of All Groups"
        $scope.$parent.groupTypeahead.selected = '';
      } else if ($stateParams.ids.length < 8 && $stateParams.type === 'timeline') {
        $scope.config.viewMode = 'group-timeline';
      } else if ($stateParams.ids.length >= 8 && this.networkData.data.attributes.primary_people.length === 1) {
        var personName = this.networkData.included[0].attributes.name;
        $scope.config.viewMode = 'individual-force';
        $scope.$parent.config.person1 = $stateParams.ids;
        $scope.networkName = "Hooke Network of " + personName;
        $scope.$parent.personTypeahead.selected = personName;
        $scope.$parent.sharedTypeahead.selected = '';
        $scope.$parent.config.viewObject = 0;
      } else if ($stateParams.ids.length > 8 && this.networkData.data.attributes.primary_people.length === 2) {
        $scope.config.viewMode = 'shared-network';
        $scope.networkName = "Hooke Network of " + this.networkData.included[0].attributes.name + " & " + this.networkData.included[1].attributes.name;
        // $scope.$parent.personTypeahead.selected = this.networkData.included[0].attributes.name;
        // $scope.$parent.sharedTypeahead.selected = this.networkData.included[1].attributes.name;
      } else if ($stateParams.ids.length < 8) {
        $scope.config.viewMode = 'group-force';
        var groupName;
        $scope.data.included.forEach( function(item) {
          if (item.id === $scope.data.data.id) {
            groupName = item.attributes.name;
          }
        });
        $scope.groupName = groupName;
        $scope.data.included = $scope.data.included.filter(function(n) { return n.id !== $scope.data.data.id; });
        $scope.networkName = "Hooke Network of " + groupName;
        $scope.$parent.groupTypeahead.selected = groupName;
        $scope.$parent.config.viewObject = 1;
      }
    };

    // Container for data related to groups
    $scope.groups = {};

    // declare a $scope property where to store the future selections
    $scope.currentSelection = {}

    // Other groups modal window
    $scope.modalAnimationsEnabled = true;
    $scope.open = function(size, parentSelector) {
      var parentElem = parentSelector ?
        angular.element($document[0].querySelector('.modal-demo ' + parentSelector)) : undefined;
      var modalInstance = $uibModal.open({
        animation: $scope.modalAnimationsEnabled,
        ariaLabelledBy: 'modal-title',
        ariaDescribedBy: 'modal-body',
        templateUrl: './views/modal-other-groups.html',
        controller: 'ModalinstanceCtrl',
        controllerAs: '$ctrl',
        size: size,
        appendTo: parentElem,
        resolve: {
          groups: function() {
            return $scope.groups.otherGroups;
          },
          currentSelection: function() {
            return $scope.currentSelection;
          }
        }
      });
      modalInstance.result.then(function(selectedItem) {
        $scope.selected = selectedItem;
      }, function() {
        $log.info('Modal dismissed at: ' + new Date());
      });
    };

    $scope.openTable = function(size, parentSelector) {
      var parentElem = parentSelector ?
        angular.element($document[0].querySelector('.modal-demo ' + parentSelector)) : undefined;
      var modalInstance = $uibModal.open({
        animation: $scope.modalAnimationsEnabled,
        ariaLabelledBy: 'modal-table',
        ariaDescribedBy: 'modal-table-body',
        templateUrl: './views/modal-table.html',
        controller: 'ModalTableCtrl',
        controllerAs: '$ctrl',
        size: size,
        appendTo: parentElem,
        resolve: {
          data: function() {
            return $scope.data;
          },
          selectedPerson: function() {
            return $scope.selectedPerson;
          },
          viewMode: function() {
            return $scope.config.viewMode;
          },
          groupSelected: function() {
            return $scope.groupSelected;
          }
        }
      });
      modalInstance.result.then(function(selectedItem) {
        $scope.selected = selectedItem;
      }, function() {
        $log.info('Modal dismissed at: ' + new Date());
      });
    };

    $scope.data4groups = function() {
      console.log('Creating data4groups');
      // GET DATA FOR GROUPS
      // use lodash to create a dictionary with groupId as key and group occurrencies as value (eg '81': 17)
      var data4groups = $scope.data.included;
      var listGroups = [];
      data4groups.forEach(function(d) {
        if (d.attributes.groups) {
          d.attributes.groups.forEach(function(e) {
            listGroups.push(e);
          })
        }
      });
      apiService.getGroups(listGroups.toString()).then(function (result) {

        listGroups = _.countBy(listGroups);

        //Transform that dictionary into an array of objects (eg {'groupId': '81', 'value': 17})
        var arr = [];
        result.data.forEach(function (d) {
            var obj = {
              'name': d.attributes.name,
              'groupId': d.id,
              'value': listGroups[d.id]
            }
            arr.push(obj);
        });

        //Sort the array in descending order
        arr.sort(function(a, b) {
          return d3.descending(a.value, b.value);
        })
        var cutAt = 20;
        var groupsBar = _.slice(arr, 0, cutAt);
        var otherGroups = _.slice(arr, cutAt);
        var othersValue = 0;
        otherGroups.forEach(function(d) {
          othersValue += d.value;
        });
        groupsBar.push({ 'groupId': 'others', 'value': othersValue, 'amount': otherGroups.length });

        $scope.groups.groupsBar = groupsBar;
        $scope.groups.otherGroups = otherGroups;
        $scope.updateGroupBar($scope.groups);

        // $scope.$emit('Update the groups bar', $scope.groups)
      });
    }

    //Functions for zoom and recenter buttons
    $scope.centerNetwork = function() {
      console.log("Recenter");
      if ($scope.config.viewMode == 'individual-force' || $scope.config.viewMode == 'individual-concentric') {
        var nodes = $scope.data.included;
        var sourceId = $scope.data.data.attributes.primary_people;
        var sourceNode = nodes.filter(function(d) { return (d.id == sourceId) })[0]; // Get source node element by its ID
        // Transition source node to center of rect
        $scope.singleSvg.transition().duration(750).call($scope.singleZoom.transform, d3.zoomIdentity.translate($scope.singleWidth / 2 - sourceNode.x, $scope.singleHeight / 2 - sourceNode.y));
      } else if ($scope.config.viewMode == 'shared-network' || $scope.config.viewMode == 'group-force') {
        $scope.singleSvg.transition().duration(750).call($scope.singleZoom.transform, d3.zoomIdentity);
      } else if ($scope.config.viewMode == 'all') {
        $scope.allGroupSvg.transition().duration(750).call($scope.allGroupZoom.transform, d3.zoomIdentity);
      }
    }

    $scope.zoomIn = function() {
      console.log("Zoom In")
      if ($scope.config.viewMode == 'individual-force' || $scope.config.viewMode == 'individual-concentric') {
        $scope.singleSvg.transition().duration(500).call($scope.singleZoom.scaleBy, $scope.singleZoomfactor + .5); // Scale by adjusted $scope.zoomfactor
      } else if ($scope.config.viewMode == 'shared-network' || $scope.config.viewMode == 'group-force') {
        $scope.singleSvg.transition().duration(500).call($scope.singleZoom.scaleBy, $scope.singleZoomfactor + .5); // Scale by adjusted $scope.zoomfactor
      } else if ($scope.config.viewMode == 'all') {
        $scope.allGroupSvg.transition().duration(500).call($scope.allGroupZoom.scaleBy, $scope.allGroupZoomfactor + .5); // Scale by adjusted $scope.zoomfactor
      }
    }
    $scope.zoomOut = function() {
      console.log("Zoom Out")
      // Scale by adjusted $scope.zoomfactor, slightly lower since zoom out was more dramatic
      if ($scope.config.viewMode == 'individual-force' || $scope.config.viewMode == 'individual-concentric') {
        $scope.singleSvg.transition().duration(500).call($scope.singleZoom.scaleBy, $scope.singleZoomfactor - .25); // Scale by adjusted $scope.zoomfactor
      } else if ($scope.config.viewMode == 'shared-network' || $scope.config.viewMode == 'group-force') {
        $scope.singleSvg.transition().duration(500).call($scope.singleZoom.scaleBy, $scope.singleZoomfactor - .25); // Scale by adjusted $scope.zoomfactor
      } else if ($scope.config.viewMode == 'all') {
        $scope.allGroupSvg.transition().duration(500).call($scope.allGroupZoom.scaleBy, $scope.allGroupZoomfactor - .25); // Scale by adjusted $scope.zoomfactor
      }
    }

    $scope.sendData = function() {
      console.log($scope.addToDB);
      $scope.addToDB = {nodes: [], links: [], groups: []};
      $scope.newNode = {};
      $scope.newLink = {};
      $scope.newGroup = {};
      $scope.groupAssign = {person: {}, group: {}};
      $scope.addedNodeId = 0;
      $window.alert("Updates Submitted! They'll show up on the website once they've been approved by a curator.")
    }


    $scope.$watch('$parent.config.contributionMode', function(newValue, oldValue) {
      // var emptyDB = {nodes: [], links: [], groups: []}
      if (newValue !== oldValue && !newValue) {
        if ($scope.addToDB.nodes.length !== 0 || $scope.addToDB.links.length !== 0 || $scope.addToDB.groups.length !== 0) {
          if ($window.confirm("You are about to turn off contribution mode, but you still have unsaved changes. Click 'cancel' and then the 'submit' button to send your changes to the database before exiting contribution mode. Discard changes and continue anyway?") === true) {
            $scope.addedNodes = [];
            $scope.addedLinks = [];
            $scope.addedGroups = [];
            $scope.newNode = {};
            $scope.newLink = {source:{}, target: {}};
            $scope.newGroup = {};
            $scope.groupAssign = {person: {}, group: {}};
            $scope.updateNetwork($scope.data);
          };
        }
        else {
          $scope.addedNodes = [];
          $scope.addedLinks = [];
          $scope.addedGroups = [];
          $scope.newNode = {};
          $scope.newLink = {source:{}, target: {}};
          $scope.newGroup = {};
          $scope.groupAssign = {person: {}, group: {}};
          $scope.updateNetwork($scope.data);
        }
      }
    })

    $transitions.onStart({}, function(transition) {
      if ($scope.config.contributionMode) {
        if ($window.confirm('If you leave this page without submitting your changes, they will be lost. Would you like to leave anyway?')) {
          return true;
        } else {
          return false;
        }
      }
    });


  }]
});
