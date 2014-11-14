
    // group class
function createGroup() {
  this.id = null;
  this.name = null;
  this.nodes = null;
}
    function createNodeKey(node) {
  var nodeKey = {"text": node.first, "size": getSize(node), "id": node.id,  "cluster": getCluster(node.birth)};
  return nodeKey;
}





function getSize(node) {
	// base off number of connections the node has 
  var numRels = node.rels.length;
  var nodeSize = numRels * 10;
  return nodeSize;
}

// Returns the color id based on birth year
function getCluster(year){
  if (parseInt(year) < 1550) {return 0}
  if (parseInt(year) > 1700) {return 1}
  var cluster = Math.round((parseInt(year) - 1550) / 5);
  return (2 + cluster);
}

// Returns hash of colors for nodes
function getColors(){
   return { 0:  "#A6D9CA", 1:  "#F0623E", 2:  "#B99CCA", 3:  "#B8DCF4", 
             4:  "#F9F39C", 5:  "#339998", 6:  "#6566AD", 7:  "#F89939", 
             8:  "#558FCB", 9:  "#04A287", 10: "#B53C84", 11: "#F2805C",
             12: "#79BD90", 13: "#654B9E", 14: "#DD88B8", 15: "#3D58A6",
             16: "#EF4C3A", 17: "#99CC7D", 18: "#4D6AB2", 19: "#A1D7D0",
             20: "#FABC3E", 21: "#EE6096", 22: "#DADC44", 23: "#B177B3",
             24: "#A573B1", 25: "#78CDD6", 26: "#60BD6D", 27: "#3EA7C0",
             28: "#F59485", 29: "#3F6FB6", 30: "#F8EC49", 31: "#1C57A7", }
}

// Checks if a value is in an array
function notInArray(arr, val) {
 var i = arr.length;
 while (i--) {
   if (arr[i][0] == val[0] && arr[i][1] == val[1]) {
     return false;
   }
   if (arr[i][1] == val[0] && arr[i][0] == val[1]) {
     return false;
   }
 }
 return true;
}

// Displays node information
function showNodeInfo(data, groups){
 accordion("node");
 $("#node-name").text(data.first+ " "+ data.last);
 $("#node-bdate").text(data.birth);
 $("#node-ddate").text(data.death);
 $("#node-significance").text(data.occupation);
 $("#node-group").text(groups);
 var d = new Date();
 $("#node-cite").text( data.first+ " "+ data.last + " Network Visualization. \n Six Degrees of Francis Bacon: Reassembling the Early Modern Social Network. Gen. eds. Daniel Shore and Christopher Warren. "+d.getMonth()+"/"+d.getDate()+"/"+d.getFullYear()+" <http://sixdegreesoffrancisbacon.com/>");
 $("#node-DNBlink").attr("href", "http://www.oxforddnb.com/search/quick/?quicksearch=quicksearch&docPos=1&searchTarget=people&simpleName="+data.first+"-"+data.last+"&imageField.x=0&imageField.y=0&imageField=Go");//"http://www.oxforddnb.com/view/article/"+data.id);
 $("#node-GoogleLink").attr("href", "http://www.google.com/search?q="+data.first+"+"+ data.last);
}

var node = function() {
  this.id = null;
  this.first = null;
  this.last = null;
  this.birth = null;
  this.death = null;
  this.label = null;
  this.name = null;
  this.occupation = null;
  this.edges = [];
  this.key = null;
};

function init(){
	  var people = gon.people;
      //1people = people.slice(1001,7000);
      var data = { nodes: [], edges: [], nodes_names: [], groups_names: [], nodeKeys: []};
  
  $.each(people, function(index, value) {
    var n = new node();
    n.id = value.id;
    n.first = value.first_name;
    n.last = value.last_name;
    n.birth = value.birth_year;
    n.death = value.death_year;
    n.occupation = value.historical_significance;
    
    if (value.rel_sum.length > 0) {
      n.rels = value.rel_sum[0];
      $.each(n.rels, function() {
        if (n.rels[2] != 0) {
          if (notInArray(data.edges, [n.id, n.rels[0]])) {
            var tuple_like_thing = [n.id, n.rels[0]]
            data.edges.push([n.id, n.rels[0]]);
          }
          else {
            // relationship already in data, don't add again
          }
        }
      });
    }
    else {
      n.rels = [];
    }
    data.nodes[n.id] = n;
    n.key = createNodeKey(n);
    data.nodeKeys.push(n.key);
  });


      loader = document.getElementById('loader');


      var nodes = data.nodeKeys;
      var links = data.edges;
      var el = document.getElementById("parent");
      var options = {
              width: screen.width,
              height: screen.height,
              colors: getColors()};

		var graph = new Insights(el, nodes, links, options).center().render();


        graph.zoom(.10);

}


  $(document).ready(function() {
    	init();
});

      