'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:UploadCtrl
 * @description
 * # AboutCtrl
 * Controller of the redesign2017App
 */
 angular.module('redesign2017App').component('upload', {
   templateUrl: 'views/upload.html',
   controller: ['$scope', '$stateParams', '$state', 'apiService', function($scope, $stateParams, $state, apiService) {
     $('textarea').on('dragover', function(e) {
        e.preventDefault(e);
        e.stopPropagation(e);
      });

      $('textarea').on('drop', function(e) {
        e.preventDefault(e);
        e.stopPropagation(e);
        var $textarea = this;
        var files = e.originalEvent.dataTransfer.files;
        var reader = new FileReader();
        reader.onload = function(e) {
          $textarea.value = e.target.result;
        }
        for (var i=0;i<files.length;i++) {
          reader.readAsText(files[i]);
        }
      });

      $scope.csvType = "people";
      $scope.readCSV = function() {
        var data = $('textarea').val();
        var rows = [];
        var header = data.split('\n')[0].split(",");
        console.log(header);
        data.split("\n").slice(1,).forEach(function(l) {
          var row = {};
          l.split(',').forEach(function(w, i) {
            row[header[i]] = w;
          })
          rows.push(row);
        });
        $scope.csvRows = rows;
        console.log($scope.csvRows, $scope.csvType);
        if ($scope.csvType === "people") {
          processPeople($scope.csvRows);
        }
      }

      function processPeople(rows) {
        rows.forEach(function(r) {
          apiService.personTypeahead(r.name).then(function successCallback(response) {
            if (response.data.length > 0) {
              r.found = true;
              response.data.forEach(function(p) {
                apiService.getPeople(p.id).then(function(result) {
                  r.foundPeople = result.data;
                })
              })
            } else {
              console.log('none found!');
              r.found = false;
            }
          }, function errorCallback(error) {
            console.log('error!');
            console.error(error);
          });
        });
        $scope.peopleRows = rows;
      }



 	}]
 });
