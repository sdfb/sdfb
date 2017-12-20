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
   controller: ['$scope', '$stateParams', '$state', 'apiService', '$rootScope', '$http', function($scope, $stateParams, $state, apiService, $rootScope, $http) {
     $scope.dateTypes = [{'name':'IN', 'abbr': 'IN'}, {'name': 'CIRCA', 'abbr': 'CA'}, {'name': 'BEFORE', 'abbr': 'BF'}, {'name': 'BEFORE/IN', 'abbr': 'BF/IN'},{'name': 'AFTER', 'abbr': 'AF'}, {'name': 'AFTER/IN', 'abbr': 'AF/IN'}];
     $scope.gender = ['male', 'female', 'gender_nonconforming'];
     $scope.relTypeCats = null;
     $http.get("/data/rel_cats.json").then(function(result){
         $scope.relTypeCats = result.data;
         // scope.newLink.relType = scope.config.relTypeCats[10];
     });
     $scope.slider = {
       value: 60,
       options: {
         floor: 0,
         ceil: 100,
         translate: function(v) {
             return v;
         }
       }
     };
     // scope.newLink.confidence = scope.slider.value;

     var groupStartYear,
         groupEndYear;

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
        $scope.csvRows = $.csv.toObjects(data);
        if ($scope.csvType === "people") {
          processPeople($scope.csvRows);
        } else if ($scope.csvType === "relationships") {
          processRelationships($scope.csvRows);
        }
      }

      function processPeople(rows) {
        rows.forEach(function(r) {
          if (r.id) {
            apiService.getPeople(r.id).then(function successCallback(result) {
              r.foundPeople = result.data;
              r.found = true;
              r.choice = '0';
            }, function errorCallback(error) {
              console.log(error);
            });
          } else if (r.name) {
            apiService.personTypeahead(r.name).then(function successCallback(response) {
              if (response.data.length > 0) {
                r.found = true;
                r.foundPeople = [];
                response.data.forEach(function(p) {
                  apiService.getPeople(p.id).then(function(result) {
                    r.foundPeople.push(result.data[0]);
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
          }
        });
        $scope.peopleRows = rows;
      }

      function processRelationships(rows) {
        rows.forEach(function(r) {
          r.relType = $scope.relTypeCats[10];
          if (r.source_id) {
            apiService.getPeople(r.source_id).then(function successCallback(result) {
              r.foundSourcePeople = result.data;
              r.sourceFound = true;
              r.sourceChoice = '0';
            }, function errorCallback(error) {
              console.log(error);
            });
          } else if (r.source_name) {
            apiService.personTypeahead(r.source_name).then(function successCallback(response) {
              if (response.data.length > 0) {
                r.sourceFound = true;
                r.foundSourcePeople = [];
                response.data.forEach(function(p) {
                  apiService.getPeople(p.id).then(function(result) {
                    r.foundSourcePeople.push(result.data[0]);
                  })
                })
              } else {
                console.log('none found!');
                r.sourceFound = false;
              }
            }, function errorCallback(error) {
              console.log('error!');
              console.error(error);
            });
          }
          if (r.target_id) {
            apiService.getPeople(r.target_id).then(function successCallback(result) {
              r.foundTargetPeople = result.data;
              r.targetFound = true;
              r.targetChoice = '0';
            }, function errorCallback(error) {
              console.log(error);
            });
          } else if (r.target_name) {
            apiService.personTypeahead(r.target_name).then(function successCallback(response) {
              if (response.data.length > 0) {
                r.targetFound = true;
                r.foundTargetPeople = [];
                response.data.forEach(function(p) {
                  apiService.getPeople(p.id).then(function(result) {
                    r.foundTargetPeople.push(result.data[0]);
                  })
                })
              } else {
                console.log('none found!');
                r.targetFound = false;
              }
            }, function errorCallback(error) {
              console.log('error!');
              console.error(error);
            });
          }
        });
        $scope.relRows = rows;
      }

      $scope.callGroupsTypeahead = function(val) {
        return apiService.groupsTypeahead(val);
      };
      $scope.groupSelected = function($item, $model, $label, $event) {
        console.log($item.name, $item.id, 'getting group network...');
        // $scope.groupAssign.group.id = $item.id;
        apiService.getGroups($item.id).then(function (result) {
          groupStartYear = result.data.data[0].attributes.start_year.toString();
          groupEndYear = result.data.data[0].attributes.end_year.toString();
        });
      }

      $scope.writePeople = function() {
        var addToDB = {};
        addToDB.nodes = [];
        $scope.peopleRows.forEach(function(p, i) {
          if (p.choice === 'new') {
            var newNode = {};
            p.id = i;
            newNode.id = p.id;
            newNode.name = p.name;
            newNode.historical_significance = p.historical_significance;
            newNode.birthDate = p.birth_year;
            newNode.birthDateType = p.birth_year_type.abbr;
            newNode.deathDate = p.death_year;
            newNode.deathDateType = p.death_year_type.abbr;
            newNode.gender = p.gender;
            newNode.is_approved = true;
            addToDB.nodes.push(newNode);
          }
          else {
            var chosen = p.foundPeople[parseInt(p.choice)];
            p.id = chosen.id;
            p.birth_year = chosen.attributes.birth_year;
            p.death_year = chosen.attributes.death_year;
            p.name = chosen.attributes.name;
            p.historical_significance = chosen.attributes.historical_significance;
          }
        });
        if ($scope.alsoGroupAssign) {
          addToDB.group_assignments = [];
          $scope.peopleRows.forEach(function(p) {
            var newGroupAssign = angular.copy($scope.groupAssign);
            newGroupAssign.person = {'id': parseInt(p.id)};
            newGroupAssign.group.id = parseInt(newGroupAssign.group.id);
            newGroupAssign.startDateType = $scope.dateTypes[5].abbr;
            newGroupAssign.endDateType = $scope.dateTypes[3].abbr;
            // console.log(groupStartYear, p.birth_year);
            if (p.birth_year >= groupStartYear) {
              newGroupAssign.startDate = p.birth_year;
            } else {
              newGroupAssign.startDate = groupStartYear;
            };
            if (p.death_year <= groupEndYear) {
              newGroupAssign.endDate = p.death_year;
            } else {
              newGroupAssign.endDate = groupEndYear;
            }
            delete newGroupAssign.group.name;
            newGroupAssign.is_approved = true;

            addToDB.group_assignments.push(newGroupAssign);
          })
        }
        addToDB.auth_token = $rootScope.user.auth_token;
        console.log(addToDB);
        apiService.writeData(addToDB).then(function successCallback(result) {
          console.log('success!');
        }, function errorCallback(error) {
          console.error(error);
        });
      }

      $scope.writeRelationships = function() {
        var addToDB = {};
        addToDB.nodes = [];
        addToDB.links = [];
        $scope.relRows.forEach(function(p, i) {
          var newLink = {};
          if (p.sourceChoice === 'new') {
            var newNode = {};
            newLink.source = {};
            var id = (i+1)*2 - 1;
            newNode.id = id;
            newLink.source.id = id;
            newNode.name = p.source_name;
            newNode.historical_significance = p.source_historical_significance;
            newNode.birthDate = p.source_birth_year;
            newNode.birthDateType = p.source_birth_year_type.abbr;
            newNode.deathDate = p.source_death_year;
            newNode.deathDateType = p.source_death_year_type.abbr;
            newNode.gender = p.source_gender;
            newNode.is_approved = true;
            addToDB.nodes.push(newNode);
          }
          else if (p.sourceChoice !== 'new'){
            var chosen = p.foundSourcePeople[parseInt(p.sourceChoice)];
            newLink.source = {};
            newLink.source.id = chosen.id;
          }
          if (p.targetChoice === 'new') {
            var newNode = {};
            newLink.target = {};
            var id = (i+1)*2;
            newNode.id = id;
            newLink.target.id = id;
            newNode.name = p.source_name;
            newNode.historical_significance = p.target_historical_significance;
            newNode.birthDate = p.target_birth_year;
            newNode.birthDateType = p.target_birth_year_type.abbr;
            newNode.deathDate = p.target_death_year;
            newNode.deathDateType = p.target_death_year_type.abbr;
            newNode.gender = p.target_gender;
            newNode.is_approved = true;
            addToDB.nodes.push(newNode);
          } else if (p.targetChoice !== 'new') {
            var chosen = p.foundTargetPeople[parseInt(p.targetChoice)];
            newLink.target = {};
            newLink.target.id = chosen.id;
          }
          newLink.startDate = p.start_year;
          newLink.startDateType = p.start_year_type.abbr;
          newLink.endDate = p.end_year;
          newLink.endDateType = p.end_year_type.abbr;
          newLink.relType = p.relType.id;
          newLink.confidence = p.confidence;
          newLink.citation = p.citation;
          newLink.is_approved = true;
          addToDB.links.push(newLink);
        });
        console.log(addToDB);
      }


 	}]
 });
