'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:smallTimeline
 * @description
 * # smallTimeline
 */
angular.module('redesign2017App')
  .directive('smallTimeline', ['apiService', '$timeout', function(apiService, $timeout) {
    return {
      template: '',
      restrict: 'E',
      scope: {
        details: '=',
      },
      link: function postLink(scope, element, attrs) {

        var svg = d3.select(element[0]).append('svg'),
          width = +svg.node().getBoundingClientRect().width,
          height = +svg.node().getBoundingClientRect().height;

        var x = d3.scaleLinear()
          .rangeRound([0, width])
          .domain([1450, 1750]);

        var rel_types = { '62':'Mentor/Teacher of', '61':'Sexual partner of', '53':'Rival of', '58':'Friend of', '56':'Knew in passing', '70':'Other-in-law of', '55':'Met', '68':'Ward of', '99':'Parishoner of', '101':'Lived with', '98':'Priest of', '52':'Enemy of', '94':'Rented to', '93':'Apprentice of', '92':'Employed by', '89':'Client of', '88':'Coworker of', '87':'Colleague of', '95':'Rented from', '84':'Godsibling of', '83':'Godchild of', '81':'Sibling of', '90':'Master of', '78':'Grandparent of', '77':'Great-grandparent of', '85':'Patron of', '73':'Heir(ess) of', '71':'Child-in-law of', '79':'Grandchild of', '69':'Testator to', '64':'Niece/Nephew of', '63':'Mentee/Student of', '54':'Acquaintance of', '75':'Great-grandchild of', '72':'Sibling-in-law of', '11':'Pupil/Student of', '3':'Acquaintance of', '1':'Enemy of', '5':'Knew in passing', '7':'Friend of', '13':'Aunt/Uncle of', '15':'Niece/Nephew of', '16':'Child-in-law of', '20':'Parent-in-law of', '18':'Heir(ess) of', '25':'Child of', '27':'Grandchild of', '28':'Grandparent of', '33':'Godsibling of', '34':'Client of', '35':'Collaborated with', '40':'Employed by', '41':'Employer of', '45':'Engaged to', '48':'Priest of', '50':'Lived with', '100':'Other religious', '96':'Engaged to', '57':'Close friend of', '66':'Aunt/Uncle of', '60':'Had child with', '97':'Spouse of', '91':'Employer of', '86':'Collaborated with', '82':'Godparent of', '76':'Parent of', '80':'Child of', '67':'Parent-in-law of', '74':'Guardian of', '102':'Neighbor of', '65':'Cousin of', '105':'Step-sibling of', '32':'Godparent of', '31':'Godchild of', '2':'Rival of', '4':'Met', '6':'Close friend of', '9':'Had child with', '12':'Mentor/Teacher of', '10':'Sexual partner of', '14':'Cousin of', '21':'Sibling-in-law of', '19':'Other-in-law of', '22':'Testator to', '17':'Guardian of', '24':'Great-grandparent of', '26':'Great-grandchild of', '29':'Parent of', '30':'Sibling of', '38':'Patron of', '36':'Colleague of', '37':'Coworker of', '39':'Apprentice of', '42':'Master of', '43':'Rented from', '44':'Rented to', '46':'Spouse of', '47':'Parishoner of', '59':'Admired by', '49':'Other religious relationship', '103':'Step-parent of', '51':'Neighbor of', '104':'Step-child of', '8':'Attracted to', '23':'Ward of', '107':'Debtor of', '106':'Creditor of', '109':'Correspondent of ', '111':'Had as midwife', '110':'Midwife for', '113':'Attended by', '112':'Attendant of', '108':'Schoolmate of' }


        function update() {

          // if the data type = relationship, we have start_date instead of birth_date and end_date instead of death_date
          // The way in which the data is computated is the same
          // All we need to do is just to change the structure of the data so that it respect the one of type = person

          if (scope.currentSelection.type == 'relationship') {
            if (attrs.details == 'currentSelection.target') {
              var d = scope.currentSelection.target;
              apiService.getPeople(d.id).then(function (result) {
                scope.currentSelection = result.data[0];
                makeTimeline();
              });
            }
            else if (attrs.details == 'currentSelection.source') {
              var d = scope.currentSelection.source;
              apiService.getPeople(d.id).then(function (result) {
                scope.currentSelection = result.data[0];
                makeTimeline();
              });
            }
            else {
            	if (!scope.currentSelection.attributes) {
            		scope.currentSelection.attributes = {}
            	}
              var i = scope.$parent.$index;
  	          scope.currentSelection.attributes.birth_year = scope.currentSelection.types[i].start_year;
  	          scope.currentSelection.attributes.death_year = scope.currentSelection.types[i].end_year;

  	          if(scope.currentSelection.start_year_type) {
  	          	scope.currentSelection.attributes.birth_year_type = scope.currentSelection.types[i].start_year_type
  	          }
              if(!scope.currentSelection.start_year_type) {
                scope.currentSelection.attributes.birth_year_type = 'IN'
              }
  	          if(scope.currentSelection.end_year_type) {
  	          	scope.currentSelection.attributes.death_year_type = scope.currentSelection.types[i].end_year_type
  	          }
              if(!scope.currentSelection.end_year_type) {
                scope.currentSelection.attributes.death_year_type = 'IN'
              }

	          	scope.currentSelection.attributes.relationshipKind = scope.currentSelection.types[i].type;
              scope.currentSelection.attributes.confidence = scope.currentSelection.types[i].confidence;
              makeTimeline();
              apiService.getUserName(scope.currentSelection.types[i].created_by).then(function(result) {
                scope.currentSelection.types[i].created_by_name = result.data.username;
                scope.thisType = {}
                scope.thisType.created_by = scope.currentSelection.types[i].created_by;
                var created = d3.select(element[0]).append('p')
                  .attr('class', 'person-right');
                  // .text('created by: ');
                created.append('a')
                  .attr('href', "/user/"+scope.thisType.created_by)
                  // .attr('ui-sref', "home.user({userId: thisType.created_by})")
                  .text(scope.currentSelection.types[i].created_by_name);
              });
            }
          } else {
            makeTimeline();
          }


          function makeTimeline() {
            // calculate if birth and death years are too close together
            var delta = scope.currentSelection.attributes.death_year - scope.currentSelection.attributes.birth_year;

            svg.selectAll('*').remove();

            svg.append('path')
              .attr('class', 'background-line')
              .attr('d', function(d) {
                return 'M' + x(x.domain()[0]) + ',' + height / 2 + ' L' + x(x.domain()[1]) + ',' + height / 2;
              });

            svg.append('text')
              .attr('class', 'label domain')
              .attr("x", function(d) {
                return x(x.domain()[0]);
              })
              .attr("y", function(d) {
                return height / 2 - 6;
              })
              .text(function(d) {
                return x.domain()[0]
              });

            svg.append('text')
              .attr('class', 'label domain')
              .attr('text-anchor', 'end')
              .attr("x", function(d) {
                return x(x.domain()[1]);
              })
              .attr("y", function(d) {
                return height / 2 - 6;
              })
              .text(function(d) {
                return x.domain()[1]
              });

            svg.append('path')
              .attr('class', 'life')
              .attr('d', function(d) {
                return 'M' + x(scope.currentSelection.attributes.birth_year) + ',' + height / 2 + ' L' + x(scope.currentSelection.attributes.death_year) + ',' + height / 2;
              });

            svg.append('path')
              .attr('class', function(d) {
                var classes = (scope.currentSelection.attributes.birth_year_type == 'CA' || scope.currentSelection.attributes.birth_year_type == 'ca') ? 'terminator birth filled' : 'terminator birth';
                return classes;
              })
              .attr('d', function(d) {
                return terminators('birth', scope.currentSelection.attributes.birth_year_type, x(scope.currentSelection.attributes.birth_year), height / 2)
              });

            svg.append('path')
              .attr('class', function(d) {
                var classes = (scope.currentSelection.attributes.death_year_type == 'CA' || scope.currentSelection.attributes.death_year_type == 'ca') ? 'terminator birth filled' : 'terminator birth';
                return classes
              })
              .attr('d', function(d) {
                return terminators('death', scope.currentSelection.attributes.death_year_type, x(scope.currentSelection.attributes.death_year), height / 2)
              });

            svg.append('text')
              .attr('class', 'label life')
              .attr("x", function(d) {
                return x(scope.currentSelection.attributes.birth_year);
              })
              .attr("y", function(d) {
                return height / 2 - 8;
              })
              .classed("text-left", function(d) {
                return delta <= 25;
              })
              .text(scope.currentSelection.attributes.birth_year);

            svg.append('text')
              .attr('class', 'label life')
              .attr("x", function(d) {
                return x(scope.currentSelection.attributes.death_year);
              })
              .attr("y", function(d) {
                return height / 2 - 8;
              })
              .classed("text-right", function(d) {
                return delta <= 25;
              })
              .text(scope.currentSelection.attributes.death_year);

  						if (scope.currentSelection.type == 'relationship') {

  							svg.append('text')
  		            .attr('class', 'label relationship')
  		            .attr("x", width/2)
  		            .attr("y", function(d) {
  		              return height;
  		            })
  		            .text(rel_types[scope.currentSelection.attributes.relationshipKind]+' ('+scope.currentSelection.attributes.confidence+'% confidence)');
  						}
            }
        }

        function terminators(position, type, refX, refY, width) {
          if (!width) { width = 9 }
          if (type == 'AF' || type == 'af') {
            refX = (position == 'birth') ? (refX - width / 3) : (refX + width / 3)
            return 'M' + (refX + width / 2) + ',' + (refY - width / 2) + ' C' + (refX + width / 4) + ',' + (refY - width / 2) + ' ' + refX + ',' + (refY - width / 4) + ' ' + refX + ',' + refY + ' S' + (refX + width / 4) + ',' + (refY + width / 2) + ' ' + (refX + width / 2) + ',' + (refY + width / 2);

          } else if (type == 'AF/IN' || type == 'af/in') {
            return 'M' + (refX + width / 2) + ',' + (refY - width / 2) + ' C' + (refX + width / 4) + ',' + (refY - width / 2) + ' ' + refX + ',' + (refY - width / 4) + ' ' + refX + ',' + refY + ' S' + (refX + width / 4) + ',' + (refY + width / 2) + ' ' + (refX + width / 2) + ',' + (refY + width / 2);

          } else if (type == 'BF' || type == 'bf') {
            refX = (position == 'birth') ? (refX - width / 3) : (refX + width / 3)
            return 'M' + (refX - width / 2) + ',' + (refY - width / 2) + ' C' + (refX - width / 4) + ',' + (refY - width / 2) + ' ' + refX + ',' + (refY - width / 4) + ' ' + refX + ',' + refY + ' S' + (refX - width / 4) + ',' + (refY + width / 2) + ' ' + (refX - width / 2) + ',' + (refY + width / 2);

          } else if (type == 'BF/IN' || type == 'bf/in') {
            return 'M' + (refX - width / 2) + ',' + (refY - width / 2) + ' C' + (refX - width / 4) + ',' + (refY - width / 2) + ' ' + refX + ',' + (refY - width / 4) + ' ' + refX + ',' + refY + ' S' + (refX - width / 4) + ',' + (refY + width / 2) + ' ' + (refX - width / 2) + ',' + (refY + width / 2);

          } else if (type == 'IN' || type == 'in') {
            return 'M' + (refX) + ',' + (refY - width / 2) + ' L' + (refX) + ',' + (refY + width / 2);

          } else if (type == 'CA' || type == 'ca') {
            return 'M' + refX + ',' + (refY - width / 2) + ' C' + (refX - width / 4) + ',' + (refY - width / 2) + ',' + (refX - width / 2) + ',' + (refY - width / 4) + ',' + (refX - width / 2) + ',' + refY + ' S' + (refX - width / 4) + ',' + (refY + width / 2) + ',' + refX + ',' + (refY + width / 2) + ' S' + (refX + width / 2) + ',' + (refY + width / 4) + ',' + (refX + width / 2) + ',' + (refY) + ' S' + (refX + width / 4) + ',' + (refY - width / 2) + ',' + (refX) + ',' + (refY - width / 2) + ' z';
          } else {
            console.warn('Missing property "'+position+'_year_type". Accepted values (lowercase or uppercase): AF, AF/IN, BF, BF/IN, IN, CA.');
          }
        }

        scope.$on('selectionUpdated', function(event, arg) {
          scope.currentSelection = arg;
          update();
        });
      }
    };
  }]);
