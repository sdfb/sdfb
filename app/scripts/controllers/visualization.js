'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:VisualizationCtrl
 * @description
 * # VisualizationCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('VisualizationCtrl', function($scope, $uibModal, $http, $log, $document, $routeParams, $route, apiService, initialConfig, initialData) {
    // console.log(initialConfig,initialData);
    $scope.config = initialConfig;
    $scope.data = initialData;
    $scope.legendClosed = false;
    $scope.filtersClosed = true;
    $scope.peopleFinderClosed = true;
    $scope.addNodeClosed = true;
    $scope.addLinkClosed = true;

    // Container for data realted to groups
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

    console.log('Calling person network...')
    $scope.config.ids = $routeParams.people.split(',');
    console.log($routeParams.people.split(','));
    apiService.getNetwork($routeParams.people).then(function(result) {
      console.log('person network of',$routeParams.people.toString(),'\n',result);
      if ($scope.config.ids.length === 1) {
        result.layout = 'individual-force';
        $scope.config.viewMode = 'individual-force';
        $scope.$broadcast('force layout generate', result);
      }
      else if ($scope.config.ids.length === 2) {
        $scope.config.viewMode = 'shared-network';
        $scope.$broadcast('shared network query', result);
      }
    });


    $scope.data4groups = function() {
      console.log('Creating data4groups');
      // GET DATA FOR GROUPS
      // use lodash to create a dictionary with groupId as key and group occurrencies as value (eg '81': 17)
      var data4groups = $scope.data.included
      var listGroups = [];
      data4groups.forEach(function(d) {
        if (d.attributes.groups) {
          d.attributes.groups.forEach(function(e) {
            listGroups.push(e);
          })
        }
      });
      listGroups = _.countBy(listGroups);

      //Transform that dictionary into an array of objects (eg {'groupId': '81', 'value': 17})
      var arr = [];
      for (var group in listGroups) {
        if (listGroups.hasOwnProperty(group)) {
          var obj = {
            'groupId': group,
            'value': listGroups[group]
          }
          arr.push(obj);
        }
      }

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
      // $scope.$emit('Update the groups bar', $scope.groups)
    }
    $scope.data4groups();

    $scope.$watch('config.viewMode', function(newValue, oldValue) {
      if (newValue != oldValue) {

        // console.log('changed layout');
        if (newValue == 'individual-force') {
          $scope.data.layout = 'individual-force';
          $scope.$broadcast('force layout update', $scope.data);
        } else if (newValue == 'individual-concentric') {
          $scope.data.layout = 'individual-concentric';
          $scope.$broadcast('force layout update', $scope.data);
        } else if (newValue == 'all') {
          apiService.getFile('./data/allgroups.json').then(function successCallback(response) {
            $scope.$broadcast('Show groups graph', response);
          }, function errorCallback(response) {
            console.error("An error occured while fetching file", response);
            return response;
          });
        } else if (newValue == 'group-force') {

          console.log('force');
        //   apiService.getFile('./data/virginiacompany.json').then(function successCallback(response) {
        //     // console.log(response);
        //     $scope.$broadcast('single group', { data: response, onlyMembers: $scope.config.onlyMembers });
        //   }, function errorCallback(response) {
        //     console.error("An error occured while fetching file", response);
        //     return response;
        //   });
        //
        // } else if (newValue == 'group-timeline') {
        //   apiService.getFile('./data/virginiacompany.json').then(function successCallback(response) {
        //     $scope.$broadcast('group timeline', response );
        //   }, function errorCallback(response) {
        //     console.error("An error occured while fetching file", response);
        //     return response;
        //   });
        }

      }
    });

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
