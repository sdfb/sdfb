'use strict';

/**
 * @ngdoc service
 * @name redesign2017App.apiService
 * @description
 * # apiService
 * Factory in the redesign2017App.
 */
angular.module('redesign2017App')
  .factory('apiService', function ($q, $http) {
    // Public API here
    return {
      getFile : function(url){
        return $http({
          method: 'GET',
          url: url
        }).then(function successCallback(response){
          return response.data;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          return response;
        });
      }
    }
  });



