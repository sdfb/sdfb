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
   controller: ['$scope', '$stateParams', '$state', 'apiService', function($scope, $stateParams, $state, apiService) {
     console.log("table view!")
     $scope.config = {contributionMode: false};
     this.$onChanges = function() {

       if($stateParams.page === 'undefined') {
        $state.go('home.people', {page: '1'})
       }
       $scope.people = this.people.data;
       $scope.people.forEach(function(d) {
         apiService.getUserName(d.attributes.created_by).then(function(result) {
           d.attributes.created_by_name = result.data.username;
         });
       });
       $scope.currentPage = $stateParams.page;
       $scope.totalItems = 1590;

       $scope.pageChanged = function() {
         $state.go('home.people', {page: $scope.currentPage});
       }
     };


 	}]
 });
