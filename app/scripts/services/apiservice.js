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
      },
      getElementData : function(id, name){
        // For now, store this data as the clicked person
        // console.log(id,name);
        var birth = Math.floor(Math.random() * (1600 - 1400 + 1)) + 1400;
        var death = Math.floor(Math.random() * (1800 - 1401 + 1)) + 1401;
        return {
          "birth_year": birth,
          "death_year": death,
          "historical_significance": "lord chancellor, politician, and philosopher",
          "id": id,
          "name": name,
          "type": "people",
          "birth_year_type": "in",
          "death_year_type": "in",
          "start_year": birth,
          "start_year_type": "in",
          "end_year": death,
          "end_year_type": "in"
        }
      }
    }
  });



