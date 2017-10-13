'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:BrowseCtrl
 * @description
 * # AboutCtrl
 * Controller of the redesign2017App
 */
 angular.module('redesign2017App').component('browse', {
   bindings: { tableData: '<' },
   templateUrl: 'views/browse.html',
   controller: ['$scope', '$stateParams', function($scope, $stateParams) {
     console.log("table view!")
     $scope.config = {contributionMode: false};
     this.$onChanges = function() {
       $scope.data = this.tableData;
       $scope.people = []
       $scope.data.split('\n').slice(1,50).forEach(function(d,i) {
         var person_data = d.split(',');
         if (i > 0) {
           var person = {};
           person_data.forEach(function(p,i) {
             person[$scope.data.split('\n')[0].split(',')[i]] = p;
           });
           $scope.people.push(person);
         }
       });
       console.log($scope.people.slice(0,5));
     };


 	}]
 });
