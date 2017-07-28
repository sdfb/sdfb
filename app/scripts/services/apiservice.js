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
    var CORSproxy = 'https://crossorigin.me/';
    // CORSproxy = '';
    var apiUrl = 'http://sixdegrees-api.herokuapp.com';
    var baseUrl = CORSproxy + apiUrl;
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
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      groupsTypeahead : function(val) {
        var url = baseUrl + '/api/typeahead';
        return $http({
          method: 'GET',
          url : url,
          params: {
              q: val,
              type: 'group'
            }
        }).then(function successCallback(response){
          console.log('response:',response);
          return response.data;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        })
      },
      getGroups : function(ids){
        // Works for a single group as well, just call with a singular ID
        var url = baseUrl + '/api/groups';
        return $http({
          method: 'GET',
          url: url,
          params: {
              ids: ids
            }
        }).then(function successCallback(response){
          return response.data;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      getGroupNetwork : function(ids){
        var url = baseUrl + '/api/groups/network';
        return $http({
          method: 'GET',
          url: url,
          params: {
              ids: ids.toString()
            }
        }).then(function successCallback(response){
          return response.data;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      getSharedNetwork : function(ids){

        var url = baseUrl + '/api/network';
        return $http({
          method: 'GET',
          url: url,
          params: {
              ids: ids.toString()
            }
        }).then(function successCallback(response){
          return response.data;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      }
    }
  });



