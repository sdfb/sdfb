'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:groupsBar
 * @description
 * # groupsBar
 */
angular.module('redesign2017App')
  .directive('groupsBar', function () {
    return {
      template: '',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the groupsBar directive');
        
		var x = d3.scaleLinear()
        updateGroupBar(scope.groups);


        function updateGroupBar(data) {
        	console.log(data.groupsBar);

        	var width = d3.select(element[0]).node().getBoundingClientRect().width;  	
        	var padding = 5;
        	width -= 20;
        	width -= padding*20;
        	console.log(width)

        	var oldWidth = d3.select(element[0]).node().getBoundingClientRect().width;
        	

        	var total=0;
        	data.groupsBar.forEach(function(d){
        		total += d.value;
        	})
        	console.log(total)


        	x.domain([0,total]);
        	x.range([0,width]);

        	

        	var chart = d3.select(element[0]).selectAll('group')
        			.data(data.groupsBar)

        	chart.enter()
        		.append('div')
        		.attr('class', 'group')
        		.style('width', function(d){
        			var myWidth = x(d.value)/(width)*100;
        			var newTot = width/oldWidth*100;
        			var value = (myWidth*newTot)/100;
        			return value+'%';
        		})
        		.merge(chart)
        		.text(function(d,i){
        			if(i==20) {
        				return 'other '+d.value+' groups (click to show)'
        			} else {
        				return 'g'+d.groupId;
        			}
        		})

        	chart.exit().remove();
        }

      }
    };
  });
