'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:BrowseCtrl
 * @description
 * # AboutCtrl
 * Controller of the redesign2017App
 */
 angular.module('redesign2017App').component('people', {
   bindings: { people: '<' },
   templateUrl: 'views/people.html',
   controller: ['$scope', '$stateParams', '$state', function($scope, $stateParams, $state) {
     console.log("table view!")
     $scope.config = {contributionMode: false};
     this.$onChanges = function() {
       $scope.people = this.people.data;
       console.log($scope.people);
       $scope.currentPage = $stateParams.page;
       $scope.totalItems = 1590;

       $scope.pageChanged = function() {
         $state.go('home.people', {page: $scope.currentPage});
       }
       // $scope.people = []
       // $scope.data.split('\n').slice(1,50).forEach(function(d,i) {
       //   var person_data = d.split(',');
       //   if (i > 0) {
       //     var person = {};
       //     person_data.forEach(function(p,i) {
       //       person[$scope.data.split('\n')[0].split(',')[i]] = p;
       //     });
       //     $scope.people.push(person);
       //   }
       // });
       // console.log($scope.people.slice(0,5));
     };


 	}]
 });
