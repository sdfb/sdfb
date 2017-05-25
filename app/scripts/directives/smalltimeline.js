'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:smallTimeline
 * @description
 * # smallTimeline
 */
angular.module('redesign2017App')
  .directive('smallTimeline', function () {
    return {
      template: '<svg></svg>',
      restrict: 'E',
      scope: {
        details: '=',
    	},
      link: function postLink(scope, element, attrs) {
        // adjust temporal variables
        if (scope.details.birth_year) {
        	scope.details.start_year = scope.details.birth_year;
        	scope.details.start_year_type = scope.details.birth_year_type;
        	scope.details.end_year = scope.details.death_year;
        	scope.details.end_year_type = scope.details.death_year_type;
        }

        var svg = d3.select(element[0]).select('svg'),
			width = +svg.node().getBoundingClientRect().width,
			height = +svg.node().getBoundingClientRect().height;

		var x = d3.scaleLinear()
                .rangeRound([0, width])
                .domain([1400, 1800]);

        svg.append('path')
	        .attr('class','background-line')
	        .attr('d', function(d){
	            return 'M'+x(x.domain()[0])+','+height/2+' L'+x(x.domain()[1])+','+height/2;
	        });

	    svg.append('text')
	    	.attr('class','label')
	        .attr("x", function(d) { return x(x.domain()[0]); })
	        .attr("y", function(d) { return height/2; })
	        .text(function(d){return x.domain()[0] });

	    svg.append('text')
	    	.attr('class','label')
	    	.attr('text-anchor', 'end')
	        .attr("x", function(d) { return x(x.domain()[1]); })
	        .attr("y", function(d) { return height/2; })
	        .text(function(d){return x.domain()[1] });

	    svg.append('path')
	    	.attr('class','life')
	        .attr('d', function(d){
	            return 'M'+x(scope.details.start_year)+','+height/2+' L'+x(scope.details.end_year)+','+height/2;
	        });

	    svg.append('path')
	        .attr('class', function(d){
	            var classes = (scope.details.start_year_type=='CA' || scope.details.start_year_type=='ca')?'terminator birth filled':'terminator birth';
	            return classes;
	        })
	        .attr('d', function(d){
	        	return terminators('birth', scope.details.start_year_type, x(scope.details.start_year), height/2 )
	        });

	    svg.append('path')
	        .attr('class', function(d){
	            var classes = (scope.details.end_year_type=='CA' || scope.details.end_year_type=='ca')?'terminator birth filled':'terminator birth';
	            return classes
	        })
	        .attr('d', function(d){
	        	return terminators('death', scope.details.end_year_type, x(scope.details.end_year), height/2 )
	        });

	    svg.append('text')
	    	.attr('class','label life')
	        .attr("x", function(d) { return x(scope.details.start_year); })
	        .attr("y", function(d) { return height/2-5; })
	        .text(scope.details.start_year);

	    svg.append('text')
	    	.attr('class','label life')
	        .attr("x", function(d) { return x(scope.details.end_year); })
	        .attr("y", function(d) { return height/2-5; })
	        .text(scope.details.end_year);


	    function terminators(position, type, refX, refY, width){
	        if(!width) { width=9 }
	        if (type == 'AF' || type == 'af') {
	            refX = (position=='birth')?(refX-width/3):(refX+width/3)
	            return 'M'+(refX+width/2)+','+(refY-width/2)+' C'+(refX+width/4)+','+(refY-width/2)+' '+refX+','+(refY-width/4)+' '+refX+','+refY+' S'+(refX+width/4)+','+(refY+width/2)+' '+(refX+width/2)+','+(refY+width/2);

	        } else if(type == 'AF/IN' || type == 'af/in'){
	            return 'M'+(refX+width/2)+','+(refY-width/2)+' C'+(refX+width/4)+','+(refY-width/2)+' '+refX+','+(refY-width/4)+' '+refX+','+refY+' S'+(refX+width/4)+','+(refY+width/2)+' '+(refX+width/2)+','+(refY+width/2);

	        } else if(type == 'BF' || type == 'bf'){
	            refX = (position=='birth')?(refX-width/3):(refX+width/3)
	            return 'M'+(refX-width/2)+','+(refY-width/2)+' C'+(refX-width/4)+','+(refY-width/2)+' '+refX+','+(refY-width/4)+' '+refX+','+refY+' S'+(refX-width/4)+','+(refY+width/2)+' '+(refX-width/2)+','+(refY+width/2);

	        } else if(type == 'BF/IN' || type == 'bf/in'){
	            return 'M'+(refX-width/2)+','+(refY-width/2)+' C'+(refX-width/4)+','+(refY-width/2)+' '+refX+','+(refY-width/4)+' '+refX+','+refY+' S'+(refX-width/4)+','+(refY+width/2)+' '+(refX-width/2)+','+(refY+width/2);

	        } else if(type == 'IN' || type == 'in'){
	            return 'M'+(refX)+','+(refY-width/2)+' L'+(refX)+','+(refY+width/2);

	        } else if (type == 'CA' || type == 'ca'){
	            return 'M'+refX+','+(refY-width/2)+' C'+(refX-width/4)+','+(refY-width/2)+','+(refX-width/2)+','+(refY-width/4)+','+(refX-width/2)+','+refY+' S'+(refX-width/4)+','+(refY+width/2)+','+refX+','+(refY+width/2)+' S'+(refX+width/2)+','+(refY+width/4)+','+(refX+width/2)+','+(refY)+', S'+(refX+width/4)+','+(refY-width/2)+','+(refX)+','+(refY-width/2)+' z'
	        }
	    }

        // console.log('details', scope.details);
        console.log( 'timeline drawn' );
      }
    };
  });
