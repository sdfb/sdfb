'use strict';

/**
 * @ngdoc service
 * @name redesign2017App.apiService
 * @description
 * # apiService
 * Factory in the redesign2017App.
 */
angular.module('redesign2017App')
  .factory('apiService', function ($q, $http, $cookieStore) {
    // var CORSproxy = 'https://crossorigin.me/';
    // CORSproxy = '';
    // var apiUrl = 'http://sixdegrees-api.herokuapp.com';
    // var apiUrl = "http://ec2-54-242-188-143.compute-1.amazonaws.com/tools"


    var apiUrl = "http://sixdegr-dev.library.cmu.edu/tools"
    // var baseUrl = CORSproxy + apiUrl;
    var baseUrl = apiUrl;
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
          return response.data;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        })
      },
      personTypeahead : function(val) {
        var url = baseUrl + '/api/typeahead';
        return $http({
          method: 'GET',
          url : url,
          params: {
              q: val,
              type: 'person'
            }
        }).then(function successCallback(response){
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
          return response;
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
      getAllGroups : function(){
        // Works for a single group as well, just call with a singular ID
        var url = baseUrl + '/api/groups';
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
      getNetwork : function(ids){

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
      },
      getPeople : function(ids){

        var url = baseUrl + '/api/people';
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
      getRelationship : function(ids){

        var url = baseUrl + '/api/relationships';
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
      writeData : function(data){

        var url = baseUrl + '/api/write';
        return $http({
          method: 'POST',
          url: url,
          data: angular.toJson(data)
        }).then(function successCallback(response){
          return response;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      logIn : function(data){

        var url = baseUrl + '/api/sign_in';
        return $http({
          method: 'POST',
          url: url,
          data: JSON.stringify(data)
        }).then(function successCallback(response){
          return response;

        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      logOut : function(data){

        var url = baseUrl + '/api/sign_out';
        return $http({
          method: 'POST',
          url: url,
          data: JSON.stringify(data)
        }).then(function successCallback(response){
          return response;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      getUser : function(id, token){

        var url = baseUrl + '/api/users';
        return $http({
          method: 'GET',
          url: url,
          params: {
              id: id,
              auth_token: token
            }
        }).then(function successCallback(response){
          return response;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      newUser : function(data){

        var url = baseUrl + '/api/new_user';
        return $http({
          method: 'POST',
          url: url,
          data: JSON.stringify(data)
        }).then(function successCallback(response){
          return response;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      editUser : function(data){

        var url = baseUrl + '/api/edit_user';
        return $http({
          method: 'POST',
          url: url,
          data: JSON.stringify(data)
        }).then(function successCallback(response){
          return response;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      requestReset : function(data){

        var url = baseUrl + '/api/request_password_reset';
        return $http({
          method: 'POST',
          url: url,
          data: JSON.stringify(data)
        }).then(function successCallback(response){
          return response;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      resetPassword : function(data){

        var url = baseUrl + '/api/password_reset';
        return $http({
          method: 'POST',
          url: url,
          data: JSON.stringify(data)
        }).then(function successCallback(response){
          return response;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      curatePeople : function(token){

        var url = baseUrl + '/api/curate/people';
        return $http({
          method: 'GET',
          url: url,
          params: {
              auth_token: token
            }
        }).then(function successCallback(response){
          return response.data;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      curateRelationships : function(token){

        var url = baseUrl + '/api/curate/relationships';
        return $http({
          method: 'GET',
          url: url,
          params: {
              auth_token: token
            }
        }).then(function successCallback(response){
          return response.data;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      curateRelTypes : function(token){

        var url = baseUrl + '/api/curate/links';
        return $http({
          method: 'GET',
          url: url,
          params: {
              auth_token: token
            }
        }).then(function successCallback(response){
          return response.data;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      curateGroups : function(token){

        var url = baseUrl + '/api/curate/groups';
        return $http({
          method: 'GET',
          url: url,
          params: {
              auth_token: token
            }
        }).then(function successCallback(response){
          return response.data;
        },function errorCallback(response){
          console.error("An error occured while fetching file",response);
          console.warn("If the issue is related to CORS Origin, try install this extention on Chrome: https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi")
          return response;
        });
      },
      curateGroupAssignments : function(token){

        var url = baseUrl + '/api/curate/group_assignments';
        return $http({
          method: 'GET',
          url: url,
          params: {
              auth_token: token
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
