'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:VisualizationCtrl
 * @description
 * # VisualizationCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('VisualizationCtrl', function($scope, $uibModal, $http, $log, $document, $routeParams, $route, $location, $window, apiService, initialConfig, initialData) {
    // console.log(initialConfig,initialData);
    $scope.config = initialConfig;
    $scope.data = initialData;
    $scope.legendClosed = false;
    $scope.filtersClosed = true;
    $scope.peopleFinderClosed = true;
    $scope.addNodeClosed = true;
    $scope.addLinkClosed = true;
    $scope.groupAssignClosed = true;
    $scope.addToDB = {nodes: [], links: [], groups: []};
    $scope.newNode = {};
    $scope.newLink = {};
    $scope.groupAssign = {person: {}, group: {}};
    if ($routeParams.ids === undefined) {
      $location.search('ids', $scope.config.ids.toString());
    }

    // Container for data related to groups
    $scope.groups = {};
    // $scope.groups.groupsBar = [];
    // $scope.groups.otherGroups = [];

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

    if ($routeParams.ids == undefined) {
      $scope.config.ids = '10000473';
      $scope.config.viewMode = 'individual-force';
    }
    else if ($routeParams.ids.length >= 8) {
      $scope.config.ids = $routeParams.ids.split(',');
      if ($scope.config.ids.length === 1) {
        $scope.config.viewMode = 'individual-force';
      }
      else if ($scope.config.ids.length === 2) {
        $scope.config.viewMode = 'shared-network';
      }
    } else {
      $scope.config.ids = $routeParams.ids.split(",");
      $scope.config.viewMode = 'group-force';
      apiService.getGroups($scope.config.ids.toString()).then(function(result) {
        $scope.groupName = result.data[0].attributes.name;
      });
    }

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
        console.log($scope.groups);
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
      } else if ($scope.config.viewMode == 'shared-network') {
        $scope.sharedSvg.transition().duration(750).call($scope.sharedZoom.transform, d3.zoomIdentity);
      } else if ($scope.config.viewMode == 'group-force') {
        $scope.groupSvg.transition().duration(750).call($scope.groupZoom.transform, d3.zoomIdentity);
      }
    }

    $scope.zoomIn = function() {
      console.log("Zoom In")
      if ($scope.config.viewMode == 'individual-force' || $scope.config.viewMode == 'individual-concentric') {
        $scope.singleSvg.transition().duration(500).call($scope.singleZoom.scaleBy, $scope.singleZoomfactor + .5); // Scale by adjusted $scope.zoomfactor
      } else if ($scope.config.viewMode == 'shared-network') {
        $scope.sharedSvg.transition().duration(500).call($scope.sharedZoom.scaleBy, $scope.sharedZoomfactor + .5); // Scale by adjusted $scope.zoomfactor
      } else if ($scope.config.viewMode == 'group-force') {
        $scope.groupSvg.transition().duration(500).call($scope.groupZoom.scaleBy, $scope.groupZoomfactor + .5); // Scale by adjusted $scope.zoomfactor
      }
    }
    $scope.zoomOut = function() {
      console.log("Zoom Out")
      // Scale by adjusted $scope.zoomfactor, slightly lower since zoom out was more dramatic
      if ($scope.config.viewMode == 'individual-force' || $scope.config.viewMode == 'individual-concentric') {
        $scope.singleSvg.transition().duration(500).call($scope.singleZoom.scaleBy, $scope.singleZoomfactor - .25); // Scale by adjusted $scope.zoomfactor
      } else if ($scope.config.viewMode == 'shared-network') {
        $scope.sharedSvg.transition().duration(500).call($scope.sharedZoom.scaleBy, $scope.sharedZoomfactor - .25); // Scale by adjusted $scope.zoomfactor
      } else if ($scope.config.viewMode == 'group-force') {
        $scope.groupSvg.transition().duration(500).call($scope.groupZoom.scaleBy, $scope.groupZoomfactor - .25); // Scale by adjusted $scope.zoomfactor
      }
    }

    $scope.sendData = function() {
      console.log($scope.addToDB);
      $scope.addToDB = {nodes: [], links: [], groups: []};
    }


    $scope.$watch('config.ids', function(newValue, oldValue) {
      if (newValue != oldValue || oldValue instanceof Array) {
        if ($scope.config.viewMode == 'individual-force') {
          $scope.data.layout = 'individual-force';
          console.log('Calling person network...')
          apiService.getNetwork($scope.config.ids.toString()).then(function(result) {
            console.log('person network of',$scope.config.ids.toString(),'\n',result);
            result.layout = 'individual-force';
            $scope.config.viewMode = 'individual-force';
            $scope.$broadcast('force layout generate', result);
            $scope.data4groups();
          });
        } else if ($scope.config.viewMode === 'shared-network') {
            console.log("Calling shared network...")
            apiService.getNetwork($scope.config.ids.toString()).then(function(result) {
              console.log('shared network of',$scope.config.ids.toString(),'\n',result);
              $scope.$broadcast('shared network generate', result);
              $scope.data4groups();
            });
        } else if ($scope.config.viewMode == 'group-force') {
            console.log("Calling group network...")
            apiService.getGroupNetwork($scope.config.ids.toString()).then(function(result) {
              console.log('group network of',$scope.config.ids.toString(),'\n',result);
              $scope.$broadcast('single group update', result);
              $scope.$broadcast('group timeline', result);
            });
        }
      }
    });


    $scope.$watch('config.viewMode', function(newValue, oldValue) {
      if (newValue !== oldValue) {
        if (newValue == 'individual-concentric') {
          $scope.data.layout = 'individual-concentric';
          $scope.$broadcast('force layout update', $scope.data);
        } else if (newValue == 'all') {
          apiService.getFile('./data/allgroups.json').then(function successCallback(response) {
            $scope.$broadcast('Show groups graph', response);
          }, function errorCallback(response) {
            console.error("An error occured while fetching file", response);
            return response;
          });
        } else if (newValue == 'individual-force' && oldValue == 'individual-concentric') {
          $scope.data.layout = 'individual-force';
          $scope.$broadcast('force layout update', $scope.data);
        }
      }
    });

    $scope.$watch('config.contributionMode', function(newValue, oldValue) {
      // var emptyDB = {nodes: [], links: [], groups: []}
      if (newValue !== oldValue && !newValue) {
        if ($scope.addToDB.nodes.length !== 0 || $scope.addToDB.links.length !== 0 || $scope.addToDB.groups.length !== 0) {
          $window.alert("You are about to turn off contribution mode, but you still have unsaved changes. Click the 'submit' button to send your changes to the database before exiting contribution mode.");
          $scope.config.contributionMode = true;
        }
        else {
          if ($scope.config.viewMode === 'individual-force' || $scope.config.viewMode === 'individual-concentric') {
            $scope.addedNodes = [];
            $scope.addedLinks = [];
            $scope.updatePersonNetwork($scope.data);
          } else if ($scope.config.viewMode === 'shared-network') {
            $scope.addedSharedNodes = [];
            $scope.addedSharedLinks = [];
            $scope.updateSharedNetwork($scope.data);
          } else if ($scope.config.viewMode === 'group-force') {
            $scope.addedGroupNodes = [];
            $scope.addedGroupLinks = [];
            $scope.updateSharedNetwork($scope.data, $scope.data.onlyMembers);
          }
        }
      }
    })

    $scope.$watch('config.onlyMembers', function(newValue, oldValue) {
      if (newValue !== oldValue) {
        apiService.getFile('./data/virginiacompany.json').then(function successCallback(response) {
          $scope.$broadcast('single group', { data: response, onlyMembers: $scope.config.onlyMembers });
        }, function errorCallback(response) {
          console.error("An error occured while fetching file", response);
          return response;
        });
      }
    });
  });
