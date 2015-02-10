var francisID = 10000473;
//var default_confidence = 75;
//showing all relationships with a confidence of at least 40 %
var default_confidence = 40;
var default_sdate = 1400;
var default_edate = 1800;
    // group class
    


/*
Num_rels Cluster    Color
 0-1		0        orange
 2-3		1        yellow
 4-5		2        aqua blue
 6-7		3        marine blue
 8-9		4        light blue
 10-11		5      hot pink
 12+		6        purple

*/
//returns cluster number based on number of relationships the cluster has
function getClusterRels(node){
	var size = node.size;
	if (size > 100){
		return 10;
	}else{
		return (Math.floor(size / 2)) / 10;
	}

}
//returns colors based on cluster group number
function getColorsRels(){
   return { 0: "#f56046", 1: "#ffbb12", 2: "#73cab5", 3: "#1d7578", 4: "#b6dcf2", 5: "#ff00ff", 6: "#9954e2"}
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
function showNodeInfo(data){
 accordion("node");
 $("#node-name").text(data.first+ " "+ data.last);
 $("#node-bdate").text(data.birth);
 $("#node-ddate").text(data.death);
 $("#node-significance").text(data.occupation);
 $("#node-group").text(data.groups.join(","));
 console.log("HI" + data.groups);
 var d = new Date();
 $("#node-cite").text( data.first+ " "+ data.last + " Network Visualization. \n Six Degrees of Francis Bacon: Reassembling the Early Modern Social Network. Gen. eds. Daniel Shore and Christopher Warren. "+d.getMonth()+"/"+d.getDate()+"/"+d.getFullYear()+" <http://sixdegreesoffrancisbacon.com/>");
 if (data.odnb_id > 0){
  $("#node-DNBlink").attr("href", "http://www.oxforddnb.com/view/article/"+data.odnb_id);
 }else{
  $("#node-DNBlink").attr("href", "http://www.oxforddnb.com/search/quick/?quicksearch=quicksearch&docPos=1&searchTarget=people&simpleName="+data.first+"+"+data.last);
 }
 $("#node-GoogleLink").attr("href", "http://www.google.com/search?q="+data.first+"+"+ data.last);
 $("#node-discussion").attr("href", "/people/" + data.id);
 $("#node-icon-chain").attr("href", "/relationships/new?person1_id=" + data.id);
 $("#node-icon-annotate").attr("href", "/user_person_contribs/new?person_id=" + data.id);
}

var node = function() {
  this.id = null;
  this.first = null;
  this.last = null;
  this.birth = null;
  this.death = null;
  this.groups = null;
  this.label = null;
  this.name = null;
  this.occupation = null;
  this.edges = [];
  this.key = null;
  this.rels = 0;
  this.size = 0;

};

//creates a nodekey associative array with node info
function createNodeKey(node) {
  //var nodeKey = {"text": node.first + " " + node.last, "size": 4, "id": node.id,  "cluster": getCluster(node.birth)};
  var nodeKey = {"text": node.first + " " + node.last, "size": 4, "id": node.id,  "cluster": getClusterRels(node)};
  return nodeKey;
}

function peopletoarray(data){
  keys = []
  //console.log(data.nodes[10000099])
  for (var key in data.nodes) {
      keys.push(data.nodes[key].first + " " + data.nodes[key].last + " (" + data.nodes[key].birth + ")");
    }
    return keys
}

function idstoarray(data){
  keys = []
  for (var key in data.nodes) {
      keys.push(data.nodes[key].id);
    }
    return keys
}

function birthtoarray(data){
  keys = []
  for (var key in data.nodes) {
      keys.push(data.nodes[key].birth);
    }
    return keys
}

function twoDegs(id, id2, data, confidence, sdate, edate) {
  var keys = {};
  var nodes = [];
  var edges = [];
  var ids = idstoarray(data);
  var births = birthtoarray(data);

  function createGraph(id, data, confidence, sdate, edate) {
    var p = data.nodes[id];

    //if (p.rels.length > 0) { //tests to make sure main person has relationships
      console.log(data,id, confidence, sdate, edate)
      $.each(p.rels, function(index, value) {
        if (value[2] == 0 || value[1] < confidence || sdate > births[ids.indexOf(value[0])] || edate < births[ids.indexOf(value[0])]) {
          // not approved, move on or if confidence is less than 0.75
          
        }
        else {
          var q = data.nodes[value[0]]; // find person object in data by id
          keys[q.id] = createNodeKey(q); //puts nodekey into keys array
          if (notInArray(edges, [p.id, q.id])) {
            edges.push([p.id, q.id]);
          }
                // if (q && q.rels.length > 0) {
                //   $.each(q.rels, function(index, value) {
                //     if (value[2] != 0 && value[1] >= confidence && sdate < births[ids.indexOf(value[0])] && edate > births[ids.indexOf(value[0])]) { //checks again if relationship id is not zero and confidence is greater than 0.75
                //       console.log("q");
                //       var r = data.nodes[value[0]]; //sets r as data from person id referenced in relationship array
                //       keys[r.id] = createNodeKey(r); //puts nodekey in array for person 2's id
                //       if (notInArray(edges, [q.id, r.id])) {
                //           edges.push([q.id, r.id]);
                //       }
                //       if (r && r.rels.length > 0) { //repeats above code for person 2, finding 2nd deg relationships
                //         $.each(r.rels, function(index, value) {
                //           if (value[2] != 0 && value[1] >= confidence && sdate < births[ids.indexOf(value[0])] && edate > births[ids.indexOf(value[0])]) {
                //             console.log("r");
                //             var s = data.nodes[value[0]];
                //             keys[s.id] = createNodeKey(s);
                //             if (s && (s.id in keys) && notInArray(edges, [r.id, s.id])) {
                //               edges.push([r.id, s.id]);
                //             }
                //           }
                //         });
                //       }
                //     }
                //   });  
                // }
              } 
          });
      //adds main person's id referenced to keys associative array. Keys represent all data in graph
          keys[p.id] = {"text": p.first + " " + p.last, "size": 20, "id": p.id,  "cluster": getClusterRels(p)}; 

    //}  
  }
  console.log("merp");
  
  createGraph(id, data, confidence, sdate, edate);
  if (id2 != 0 && id2 != ""){
    createGraph(id2, data, confidence, sdate, edate);
  }

$.each(keys, function(index, value) {
  nodes.push(value); //adds each key to nodes array
});

edges.reverse();

  var w = window.innerWidth;
  var h = window.innerHeight;
  
  var options = { width: w, height: h, collisionAlpha: 10, colors: getColorsRels() };
  var graph = new Insights($("#graph")[0], nodes, edges, options).render();
  graph.focus(id);
  graph.on("node:click", function(d) {
    var clicked = data.nodes[d.id];
    showNodeInfo(clicked);
  });
	
  graph.on("edge:click", function(d) {
    //Pace.restart();
    var id1 = parseInt(d.source.id);
    var id2 = parseInt(d.target.id);
    //window.location.href = '/?id=' + id1 + '&id2=' + id2;
    getAnnotation(id1 < id2 ? id1 : id2, id1 > id2 ? id1 : id2, data);
  });

  graph.tooltip("<div class='btn' >{{text}}</div>");

  $('#zoom button.icon').click(function(e){
    if (this.name == 'in') {
      graph.zoomIn();
      graph.center();
    } else if (this.name == 'out') {
      graph.zoomOut();
      graph.center();
    }
  });
}

$('#zoom button.icon').click(function(e){
    if (this.name == 'in') {
      graph.zoomIn();
    } else {
      graph.zoomOut();
    }
  });

// Returns string stating confidence based on input decimal (0<n1.00)
 function getConfidence(n) {
  if (0 <= n &&  n<= 19) {
    return "very unlikely";}
  else if (20 <= n &&  n<= 39) {
    return "unlikely";}
  else if (40 <= n &&  n<= 59) {
    return "possible";}
  else if (60 <= n && n<= 79) {
    return "likely";}
  else {
    return "certain";}
 }

// Displays edge information 
function getAnnotation(id1, id2, data) {
  var id1_rel_array = data.nodes[id1].rels;
  var confidence = "";
  var rel_id = "";
  $.each(id1_rel_array, function(index, value) {                    
    if (value[0] == id2){
       confidence = getConfidence(value[1]) + " @ " + value[1] + "%";
       rel_id = value[3];
    }
  });

  accordion("edge");
  $("#edge-nodes").html(data.nodes[id1].first +" "+data.nodes[id1].last + " & " + data.nodes[id2].first+" "+data.nodes[id2].last);
  $("#edge-confidence").html(confidence);
  $("#edge-discussion").attr("href", "/relationships/" + rel_id );
  $("#edge-icon-annotate").attr("href", "/user_rel_contribs/new?relationship_id=" + rel_id );
  //$("#Sir-Mix-a-Lot").html(row.contributor); 
  //$("#edge-annotation").html(row.annotation);
  return true;
    };

  // Populates dropdowns
function populateLists(data){
  var names = peopletoarray(data);
  // $('#one').typeahead({
  //   local: names.sort()
  // });
  // $('#two').typeahead({
  //   local: names.sort()
  // });
  // $('#three').typeahead({
  //   local: names.sort()
  // });
  $('#group_name').typeahead({
    local: data.groups_names
  }).on('typeahead:selected', function (obj, datum) {
    $('#group-description').html(data.groups_desc[data.groups_names.indexOf(datum.value)]);
    $('#group-members').html(data.groups_people[data.groups_names.indexOf(datum.value)].toString());
    });
}


function getParam ( sname )
{
  var params = location.search.substr(location.search.indexOf("?")+1);
  var sval = "";
  params = params.split("&");
    // split param and value into individual pieces
    for (var i=0; i<params.length; i++)
       {
         temp = params[i].split("=");
         if ( [temp[0]] == sname ) { sval = temp[1]; }
       }
  return sval;
}

function filterGraph(data){
  var ID = getParam("id");
  var ID2 = getParam("id2");
  var conf = getParam("confidence");
  var date = getParam("date");
  var sdate = date.substring(0, 3);
  var edate = date.substring(5, 8);
  if(ID2 == "" || ID2 == "0"){
    ID2 = 0;
  } 
  if(date == ""){
    sdate = default_sdate;
    edate = default_edate;
  }
  if(ID == ""){
    ID = francisID;
  }
  if(conf == ""){
    conf = default_confidence;
  }
  twoDegs(ID, ID2, data, conf, sdate, edate);
}

function initGraph(data){
  var names = peopletoarray(data);
  var ids = idstoarray(data);

  if (getParam('id') > 0){
    $("#results").html("Two degrees of " + names[ids.indexOf(parseInt(getParam('id')))] + " at " + getParam('confidence') + "% from " + getParam('date').replace(',', ' to '));
    }

  //click methods for all the 'find' buttons in the search bar
  //this should not use the entire peopletoarray instead it should use whatever value is passed through by the #one
  $("#findonenode").click(function () {
  	var table = 'no';
    Pace.restart();
    // if ($("#one").val()) {
    //   var index = names.indexOf($("#one").val())
    // }
    // make the index equal autocomplete
    var index = $("#one_node_id_field").val();
    
    if ($("#show-table").val() == 1) {
    	table = 'yes'
    }

    var confidence = $("#slider-result-hidden1").val();
    var date = $("#search-date-hidden1").val().split(" - ");
    // '/?person_id=' + ids[index] + '&confidence=' + confidence + '&date=' + $("search-date-range1").val(); + '&table=' + table;
  	//window.location.href = '/?person_id=' + ids[index] + '&confidence=' + confidence + '&date=' + date + '&table=' + table;
    window.location.href = '/?id=' + index + '&confidence=' + confidence + '&date=' + date + '&table=' + table;
  });

   $("#findtwonode").click(function () {
      var table = 'no';
      Pace.restart();
      if ($("#two").val()) {
        var index = names.indexOf($("#two").val())
      }
      if ($("#three").val()) {
        var index2 = names.indexOf($("#three").val())
      }
      if ($("#show-table").val() == 1) {
        table = 'yes'
      }
      var confidence = $("#slideredge-result-hidden2").val();
      var date = $("#searchedge-date-hidden2").val().split(" - ");
      window.location.href = '/?id=' + ids[index] + '&id2=' + ids[index2] + '&confidence=' + confidence + '&date=' + date + '&table=' + table;
    });

  $("#nav-filter").click(function (){
    var ID = getParam("id");
    var confidence = $("#slidenav-result-hidden1").val();
    var date = $("#nav-date-range2").val().split(" - ");
    //var date = $("#searchnav-date-range1").val().split(" - ");
    if ( ID != ""){
      window.location.href = '/?id=' + ID + '&confidence=' + confidence + '&date=' + date;
    }
    if (ID == ""){
      window.location.href = '/?id=' + francisID + '&confidence=' + confidence + '&date=' + date;  
    }

  });

  $("aside button.icon").click(function(){
    addNodes = [];
    addEdges = [];
    var name = $('#node-name').html() + " (" + $('#node-bdate').html() + ")";
        if (this.id == "icon-tag") {
          $("#entry_1177061505").val(name);
        } else if (this.id == "icon-link") {
          $("#entry_768090773").val(name);
        }
  });
}

function init() {
  //This file only contains the data for the searched person and 1st degree relationships

  //This file contains all the id, first_name, last_name, ext_birth_year, prefix, suffix, and title for every person in the database


	var data = { nodes: [], edges: [], groups_names: [], groups_desc: [], groups_people: [], nodeKeys: [] };
  //var allPeopleNamesData = { nodes: [], edges: [], groups_names: [], groups_desc: [], groups_people: [], nodeKeys: [] };

  var people = window.gon.people
  var group_data = window.gon.group_data
  //var all_people = window.gon.all_people
  // var data= window.gon.data
  // var allPeopleNamesData= window.gon.allPeopleNamesData
  //This function only converts gon to all data for the searched person and 1st degree relationships
  
  if (jQuery.type(people) === "object"){
    var n = new node();
    n.id = people.id;
    n.first = people.first_name;
    n.last = people.last_name;
    n.label = n.first + " " + n.last;
    n.birth = people.ext_birth_year;
    n.death = people.ext_death_year;
    n.occupation = people.historical_significance;
    n.rels = people.rel_sum;
    n.size = n.rels.length;
    n.odnb_id = people.odnb_id;
    n.groups = people.group_list;
    data.nodes[n.id] = n;
  }else{
    console.log(people)
    $.each(people, function(index, value) { 
      var n = new node();
      n.id = value.id;
      n.first = value.first_name;
      n.last = value.last_name;
      n.label = n.first + " " + n.last;
      n.birth = value.ext_birth_year;
      n.death = value.ext_death_year;
      n.occupation = value.historical_significance;
      n.rels = value.rel_sum;
      n.size = n.rels.length;
      n.odnb_id = value.odnb_id;
      n.groups = value.group_list;
      data.nodes[n.id] = n;
    });
  }
  
  //This function converts gon to name data for all people in the database
  // $.each(all_people, function(index, value) { 
  //   var n = new node();
  //   n.id = value.id;
  //   n.first = value.first_name;
  //   n.last = value.last_name;
  //   n.prefix = value.prefix;
  //   n.suffix = value.suffix;
  //   n.title = value.title
  //   n.label = n.first + " " + n.last;
  //   n.birth = value.ext_birth_year;
  //   n.death = value.ext_death_year;
  //   allPeopleNamesData.nodes[n.id] = n;   
  // });

  //This function converts the gon for groups into readable information for groups
  $.each(group_data, function(index, value){
    data.groups_names.push(value.name);
    data.groups_desc.push(value.description);
    data.groups_people.push(value.person_list);
  });



  populateLists(data);
  filterGraph(data);
  initGraph(data);

   }


$(document).ready(function() {
  init();
});

      