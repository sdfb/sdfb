'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:RelationshipsCtrl
 * @description
 * # AboutCtrl
 * Controller of the redesign2017App
 */
 angular.module('redesign2017App').component('relationships', {
   bindings: { relationships: '<' },
   templateUrl: 'views/relationships.html',
   controller: ['$scope', '$stateParams', '$state', 'apiService', function($scope, $stateParams, $state, apiService) {
     console.log("table view!")
     $scope.config = {contributionMode: false};
     this.$onChanges = function() {

       if($stateParams.page === 'undefined') {
        $state.go('home.relationships', {page: '1'})
       }
       $scope.relationships = this.relationships.data;
       var included = this.relationships.included;
       console.log($scope.relationships);
       $scope.relationships.forEach(function(d) {
         apiService.getUserName(d.attributes.created_by).then(function(result) {
           d.attributes.created_by_name = result.data.username;
         });
         included.forEach(function(i) {
           if (i.id === d.attributes.person_1.toString()) {
             d.attributes.person_1_name = i.attributes.name;
           }
           if (i.id === d.attributes.person_2.toString()) {
             d.attributes.person_2_name = i.attributes.name;
           }
         })
       });
       $scope.currentPage = $stateParams.page;
       $scope.totalItems = 17150;

       $scope.pageChanged = function() {
         $state.go('home.relationships', {page: $scope.currentPage});
       }

       $scope.goToShared = function(sourceId,targetId) {
         var ids = [sourceId,targetId].join();
         $state.go('home.visualization', {ids: ids, type: 'network', min_confidence: '60'});
       }
       // $scope.relationships = []
       // $scope.data.split('\n').slice(1,50).forEach(function(d,i) {
       //   var person_data = d.split(',');
       //   if (i > 0) {
       //     var person = {};
       //     person_data.forEach(function(p,i) {
       //       person[$scope.data.split('\n')[0].split(',')[i]] = p;
       //     });
       //     $scope.relationships.push(person);
       //   }
       // });
       // console.log($scope.relationships.slice(0,5));
     };


 	}]
 });
