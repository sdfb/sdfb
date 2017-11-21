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
  controller: ['$scope', '$uibModal', '$http', '$log', '$document', '$location', '$window', 'apiService', '$stateParams', '$transitions', '$rootScope', function($scope, $uibModal, $http, $log, $document, $location, $window, apiService, $stateParams, $transitions, $rootScope) {
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
          layout: 'individual-force',
          login: {
            status: true,
            user: 'Elizabeth',
          },
          contributionMode: $scope.$parent.config.contributionMode,
          dateTypes : [{'name':'IN', 'abbr': 'IN'}, {'name': 'CIRCA', 'abbr': 'CA'}, {'name': 'BEFORE', 'abbr': 'BF'}, {'name': 'BEFORE/IN', 'abbr': 'BF/IN'},{'name': 'AFTER', 'abbr': 'AF'}, {'name': 'AFTER/IN', 'abbr': 'AF/IN'}],
          genderTypes : ['male', 'female', 'gender_nonconforming'],
          userId : 11,
          onlyMembers: false,
          added: false
        }

    $rootScope.config = {};

    $scope.config = initialConfig;
    $scope.personTypeahead = {selected: ''};
    $scope.sharedTypeahead = {selected: ''};
    $scope.groupTypeahead = {selected: ''};
    $rootScope.config.viewMode = $scope.config.viewMode;
    // $scope.data = initialData;
    $scope.legendClosed = false;
    $rootScope.filtersClosed = true;
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

    $scope.sampleCitation = "e.g., Gordon Campbell, ‘Milton, John (1608–1674)’, Oxford Dictionary of National Biography, Oxford University Press, 2004; online edn, Jan 2009 [http://www.oxforddnb.com.proxy.library.cmu.edu/view/article/18800, accessed 15 Nov 2017]"


    this.$onChanges = function() {
      $scope.data = this.networkData;
      if ($scope.data === 'error' || $scope.data.errors || $scope.data.data.errors) {
        $scope.noData = true;
      } else {
        if ($stateParams.type === 'all-groups') {
          $scope.config.viewMode = 'all';
          $rootScope.config.viewMode = 'all';
          $scope.config.networkName = "Co-membership Network of All Groups"
          $scope.groupTypeahead.selected = '';
          $scope.personTypeahead.selected = '';
          $scope.sharedTypeahead.selected = '';
          $scope.config.viewObject = 1;
        } else if ($stateParams.ids.length < 8 && $stateParams.type === 'timeline') {
          $scope.config.viewMode = 'group-timeline';
          $rootScope.config.viewMode = 'group-timeline';
          var groupName = $scope.data.data.data[0].attributes.name;
          $scope.config.networkName = groupName + " Timeline";
          $scope.config.networkDesc = $scope.data.data.data[0].attributes.description;
          $scope.personTypeahead.selected = '';
          $scope.sharedTypeahead.selected = '';
          $scope.config.viewObject = 1;
        } else if ($stateParams.ids.length >= 8 && this.networkData.data.attributes.primary_people.length === 1) {
          var personName = this.networkData.included[0].attributes.name;
          $scope.config.viewMode = 'individual-force';
          $rootScope.config.viewMode = 'individual-force';
          $scope.config.person1 = $stateParams.ids;
          $scope.config.networkName = personName + " Network";
          $scope.config.networkDesc = this.networkData.included[0].attributes.historical_significance;
          $scope.personTypeahead.selected = personName;
          $scope.sharedTypeahead.selected = '';
          $scope.groupTypeahead.selected = '';
          $scope.config.viewObject = 0;
        } else if ($stateParams.ids.length > 8 && this.networkData.data.attributes.primary_people.length === 2) {
          $scope.config.viewMode = 'shared-network';
          $rootScope.config.viewMode = 'shared-network';
          $scope.config.networkComplexity = 'all_connections';
          $scope.config.person1 = $stateParams.ids.split(',')[0];
          $scope.config.networkName = this.networkData.included[0].attributes.name + " & " + this.networkData.included[1].attributes.name + " Network";
          $scope.personTypeahead.selected = this.networkData.included[0].attributes.name;
          $scope.sharedTypeahead.selected = this.networkData.included[1].attributes.name;
          $scope.groupTypeahead.selected = '';
          $scope.config.viewObject = 0;
        } else if ($stateParams.ids.length < 8) {
          $scope.config.viewMode = 'group-force';
          $rootScope.config.viewMode = 'group-force';
          var groupDescription;
          if (!$scope.data.errors) {
            $scope.data.included.forEach( function(item) {
              if (item.id === $scope.data.data.id) {
                $scope.groupName = item.attributes.name;
                groupDescription = item.attributes.description;
              }
            });
            $scope.data.included = $scope.data.included.filter(function(n) { return n.id !== $scope.data.data.id; });
          } else {
            console.log($rootScope.saveGroup);
            $rootScope.saveGroup.attributes.startDateType = $rootScope.saveGroup.attributes.startDateType.abbr;
            $rootScope.saveGroup.attributes.endDateType = $rootScope.saveGroup.attributes.endDateType.abbr;
            $scope.addToDB.groups.push($rootScope.saveGroup.attributes);
            $scope.groupName = $rootScope.saveGroup.attributes.name;
            groupDescription = $rootScope.saveGroup.attributes.description;
            $scope.data = {data: {id: $stateParams.ids, attributes: {primary_people: [], connections: []}, type: "network"}, included: []};
          }
          $scope.config.networkName = $scope.groupName + " Network";
          $scope.config.networkDesc = groupDescription;
          $scope.groupTypeahead.selected = groupName;
          $scope.personTypeahead.selected = '';
          $scope.sharedTypeahead.selected = '';
          $scope.config.viewObject = 1;
        }
      }
    };

    $scope.citation = function() {
      var now = new Date()
      if ($scope.config.confidenceMax > 100) {
        $scope.config.confidenceMax = 100;
      }
      if ($scope.config.viewMode !== 'group-timeline' && $scope.config.viewMode !== 'group-force' && $scope.config.viewMode !== 'all') {
        return '"' + $scope.config.networkName + " ["+$scope.config.networkComplexity+", "+$scope.config.dateMin+"-"+$scope.config.dateMax+", "+$scope.config.confidenceMin+"-"+$scope.config.confidenceMax+'%]." Six Degrees of Francis Bacon. '+$location.$$absUrl+", "+(now.getMonth()+1)+"/"+now.getDate()+"/"+now.getFullYear() + '.';
      } else {
        return '"' + $scope.config.networkName + ' [1500-1700]." Six Degrees of Francis Bacon. '+$location.$$absUrl+", "+(now.getMonth()+1)+"/"+now.getDate()+"/"+now.getFullYear() + '.';
      }
    }

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

    // $scope.sendData = function() {
    //   console.log($scope.addToDB);
    //   $scope.addToDB = {nodes: [], links: [], groups: [], group_assignments: []};
    //   $scope.newNode = {};
    //   $scope.newNode.birthDateType = $scope.newNode.deathDateType = $scope.config.dateTypes[1];
    //   $scope.newLink = {};
    //   $scope.newGroup = {};
    //   $scope.groupAssign = {person: {}, group: {}};
    //   $scope.addedNodeId = 0;
    //   // $window.alert("Updates Submitted! They'll show up on the website once they've been approved by a curator.")
    // }

    $scope.openReview = function(size, parentSelector) {
      var parentElem = parentSelector ?
        angular.element($document[0].querySelector('.modal-demo ' + parentSelector)) : undefined;
      var modalInstance = $uibModal.open({
        animation: $scope.modalAnimationsEnabled,
        ariaLabelledBy: 'modal-review',
        ariaDescribedBy: 'modal-review-body',
        templateUrl: './views/modal-review.html',
        controller: 'ModalReviewCtrl',
        controllerAs: '$ctrl',
        size: size,
        appendTo: parentElem,
        resolve: {
          addToDB: function() {
            return $scope.addToDB;
          },
          addedNodes: function() {
            return $scope.addedNodes;
          },
          addedGroups: function() {
            return $scope.addedGroups;
          },
          addedLinks: function() {
            return $scope.addedLinks;
          },
          relTypeCats: function() {
            return $scope.relTypeCats;
          }
        }
      });
      modalInstance.result.then(function(result) {
        // result.links.forEach (function(l) {
        //   delete l.id;
        // })
        // console.log(result);
        // apiService.writeData(result);
        // $scope.addToDB = {nodes: [], links: [], groups: [], group_assignments: []};
        // $scope.addedNodes = [];
        // $scope.addedLinks = [];
        // $scope.addedGroups = [];
        // $scope.newNode = {};
        // $scope.addedNodeId = 0;
        // $scope.newLink = {source:{}, target: {}};
        // $scope.newGroup = {};
        // $scope.groupAssign = {person: {}, group: {}};
        // $scope.config.added = false;
        // $scope.updateNetwork($scope.data);
      }, function(reason) {
        console.log(reason);
        $scope.updateNetwork($scope.data);
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

      if (listGroups.length > 0) {
        apiService.getGroups(listGroups.toString()).then(function (r) {

          listGroups = _.countBy(listGroups);

          //Transform that dictionary into an array of objects (eg {'groupId': '81', 'value': 17})
          var arr = [];
          r.data.data.forEach(function (d) {
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
    }

    //Functions for zoom and recenter buttons
    $scope.centerNetwork = function() {
      console.log("Recenter");
      if ($scope.config.viewMode == 'individual-force' || $scope.config.viewMode == 'individual-concentric') {
        var nodes = $scope.data.included;
        var sourceId = $scope.data.data.attributes.primary_people;
        var sourceNode = nodes.filter(function(d) { return (d.id == sourceId) })[0]; // Get source node element by its ID
          $scope.singleSvg.transition().duration(750).call($scope.singleZoom.transform, d3.zoomIdentity.translate($scope.singleWidth / 2 - sourceNode.x, $scope.singleHeight / 2 - sourceNode.y));
        // }
      } else {
        $scope.singleSvg.transition().duration(750).call($scope.singleZoom.transform, d3.zoomIdentity);
      }
    }

    $scope.zoomIn = function() {
      console.log("Zoom In")
      if ($scope.config.viewMode == 'individual-force' || $scope.config.viewMode == 'individual-concentric') {
        $scope.singleSvg.transition().duration(500).call($scope.singleZoom.scaleBy, $scope.singleZoomfactor + .5); // Scale by adjusted $scope.zoomfactor
      } else  {
        $scope.singleSvg.transition().duration(500).call($scope.singleZoom.scaleBy, $scope.singleZoomfactor + .5); // Scale by adjusted $scope.zoomfactor
      }
    }
    $scope.zoomOut = function() {
      console.log("Zoom Out")
      // Scale by adjusted $scope.zoomfactor, slightly lower since zoom out was more dramatic
      if ($scope.config.viewMode == 'individual-force' || $scope.config.viewMode == 'individual-concentric') {
        $scope.singleSvg.transition().duration(500).call($scope.singleZoom.scaleBy, $scope.singleZoomfactor - .25); // Scale by adjusted $scope.zoomfactor
      } else {
        $scope.singleSvg.transition().duration(500).call($scope.singleZoom.scaleBy, $scope.singleZoomfactor - .25); // Scale by adjusted $scope.zoomfactor
      }
    }


    $scope.$watch('$parent.config.contributionMode', function(newValue, oldValue) {
      $scope.config.contributionMode = newValue;
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
            $scope.addToDB = {nodes: [], links: [], groups: [], group_assignments: []};
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
          $scope.addToDB = {nodes: [], links: [], groups: [], group_assignments: []};
          $scope.updateNetwork($scope.data);
        }
      }
    })

    $transitions.onStart({}, function(transition) {
      if ($scope.$parent.config.contributionMode) {
        if ($window.confirm("If you leave this page without submitting your changes, they will be lost. If you'd like to leave anyway, click 'okay'?")) {
          return true;
        } else {
          return false;
        }
      }
    });


  }]
});
