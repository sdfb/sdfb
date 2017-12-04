'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:contextualInfoPanel
 * @description
 * # contextualInfoPanel
 */
angular.module('redesign2017App')
  .directive('contextualInfoPanel', ['apiService', '$stateParams', '$rootScope', function(apiService, $stateParams, $rootScope) {
    return {
      templateUrl: './views/contextual-info-panel.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

        scope.editData = function(id) {
          console.log(id);
        }


        scope.searchODNB = function() {
          if (scope.currentSelection.type === 'person') {
            var id = scope.currentSelection.attributes.odnb_id;
            var name = scope.currentSelection.attributes.name.replace(' ','+');
            if (id) {
              var url = 'http://www.oxforddnb.com/view/article/{{id}}';
              window.open(url.replace('{{id}}', id), '_blank');
            } else {
              var url = 'http://www.oxforddnb.com/search/articles/?searchForm=%2Fsearch%2Ffulltext%2Findex.jsp&text1="{{name}}"&textFieldLimiter1=article_text&textQualifier1=+AND+&bool1=+AND+&text2=&textFieldLimiter2=article_text&textQualifier2=+AND+&bool2=+AND+&text3=&textFieldLimiter3=article_text&textQualifier3=EXACT&search=Search';
              window.open(url.replace('{{name}}', name.toLowerCase()), '_blank');
            }
          } else if (scope.currentSelection.type === 'relationship') {
            var name1 = scope.currentSelection.source.attributes.name.replace(' ','+');
            var name2 = scope.currentSelection.target.attributes.name.replace(' ','+');
            var url = 'http://www.oxforddnb.com/search/articles/?searchForm=%2Fsearch%2Ffulltext%2Findex.jsp&text1="{{name1}}"&textFieldLimiter1=article_text&textQualifier1=+AND+&bool1=+AND+&text2="{{name2}}"%20&textFieldLimiter2=article_text&textQualifier2=+AND+&bool2=+AND+&text3=&textFieldLimiter3=article_text&textQualifier3=EXACT&search=Search';
            url = url.replace('{{name1}}', name1.toLowerCase());
            url = url.replace('{{name2}}', name2.toLowerCase());
            window.open(url, '_blank');
          } else if (scope.currentSelection.type === 'group') {
            var name = scope.currentSelection.data[0].attributes.name.replace(' ','+');
            var url = 'http://www.oxforddnb.com/search/articles/?searchForm=%2Fsearch%2Ffulltext%2Findex.jsp&text1="{{name}}"&textFieldLimiter1=article_text&textQualifier1=+AND+&bool1=+AND+&text2=&textFieldLimiter2=article_text&textQualifier2=+AND+&bool2=+AND+&text3=&textFieldLimiter3=article_text&textQualifier3=EXACT&search=Search';
            window.open(url.replace('{{name}}', name.toLowerCase()), '_blank');
          }
        }

        scope.searchJstor = function() {
          if (scope.currentSelection.type === 'person') {
            var name = scope.currentSelection.attributes.name.replace(' ','+');
            var url = 'http://www.jstor.org/action/doBasicSearch?Query="{{name}}"';
            window.open(url.replace('{{name}}', name.toLowerCase()), '_blank');
          } else if (scope.currentSelection.type === 'relationship') {
            var name1 = scope.currentSelection.source.attributes.name.replace(' ','+');
            var name2 = scope.currentSelection.target.attributes.name.replace(' ','+');
            var url = 'http://www.jstor.org/action/doBasicSearch?Query="{{name1}}"+"{{name2}}"';
            url = url.replace('{{name1}}', name1.toLowerCase());
            url = url.replace('{{name2}}', name2.toLowerCase());
            window.open(url, '_blank');
          } else if (scope.currentSelection.type === 'group') {
            var name = scope.currentSelection.data[0].attributes.name.replace(' ','+');
            var url = 'http://www.jstor.org/action/doBasicSearch?Query="{{name}}"';
            window.open(url.replace('{{name}}', name.toLowerCase()), '_blank');
          }
        }

        scope.searchGoogle = function(name) {
          if (scope.currentSelection.type === 'person') {
            var name = scope.currentSelection.attributes.name.replace(' ','+');
            var url = 'http://scholar.google.com/scholar?q="{{name}}"';
            window.open(url.replace('{{name}}', name.toLowerCase()), '_blank');
          } else if (scope.currentSelection.type === 'relationship') {
            var name1 = scope.currentSelection.source.attributes.name.replace(' ','+');
            var name2 = scope.currentSelection.target.attributes.name.replace(' ','+');
            var url = 'http://scholar.google.com/scholar?q="{{name1}}"+"{{name2}}"';
            url = url.replace('{{name1}}', name1.toLowerCase());
            url = url.replace('{{name2}}', name2.toLowerCase());
            window.open(url, '_blank');
          } else if (scope.currentSelection.type === 'group') {
            var name = scope.currentSelection.data[0].attributes.name.replace(' ','+');
            var url = 'http://scholar.google.com/scholar?q="{{name}}"';
            window.open(url.replace('{{name}}', name.toLowerCase()), '_blank');
          }
        }


        scope.download = 'data:attachment/json;charset=utf-8,' +  encodeURIComponent(JSON.stringify(scope.data, null, 2));

        scope.$watch('currentSelection', function(newValue, oldValue) {

          if (newValue !== oldValue && scope.currentSelection.type) {
            $rootScope.searchClosed = true;
          }
          if (scope.currentSelection.type == 'group') {
            scope.currentSelection.includes.forEach(function(p, i) {
              p.start_year = scope.currentSelection.data[0].attributes.people[i].start_year;
              p.start_year_type = scope.currentSelection.data[0].attributes.people[i].start_year_type;
            })
            if (!scope.currentSelection.data[0].attributes.citations) {
              scope.selectionCitation = "No additional references provided upon contribution";
            } else {
              scope.selectionCitation = scope.currentSelection.data[0].attributes.citations;
            }
          };

          if (scope.currentSelection.type === 'person') {
            apiService.getUserName(scope.currentSelection.attributes.created_by).then(function(result) {
              scope.currentSelection.attributes.created_by_name = result.data.username;
            });
            if (!scope.currentSelection.attributes.citations) {
              scope.selectionCitation = "No additional references provided upon contribution";
            } else {
              scope.selectionCitation = scope.currentSelection.attributes.citations;
            }
          } else if (scope.currentSelection.type === 'group') {
            apiService.getUserName(scope.currentSelection.data[0].attributes.created_by).then(function(result) {
              scope.currentSelection.data[0].attributes.created_by_name = result.data.username;
            });
          } else if (scope.currentSelection.type === 'relationship') {
            console.log(scope.currentSelection.created_by);
            apiService.getUserName(scope.currentSelection.created_by).then(function(result) {
              scope.currentSelection.created_by_name = result.data.username;
            });
          }
        })


      }
    };
  }]);
