var francisID = 10000473;
var default_sconfidence = 60;
var default_econfidence = 100;
var default_sdate = 1400;
var default_edate = 1800;
  
// Displays node information
function showNodeInfo(personInfo){
 accordion("node");
 $("#node-name").text(personInfo.display_name);
 $("#node-bdate").text(personInfo.birth_year_type + " " + personInfo.birth_year);
 $("#node-ddate").text(personInfo.death_year_type + " " + personInfo.death_year);
 $("#node-significance").text(personInfo.occupation);
 $("#node-group").text(personInfo.groups.join(","));
 var d = new Date();
 $("#node-cite").text( personInfo.first+ " "+ personInfo.last + " Network Visualization. \n Six Degrees of Francis Bacon: Reassembling the Early Modern Social Network. Gen. eds. Daniel Shore and Christopher Warren. "+d.getMonth()+"/"+d.getDate()+"/"+d.getFullYear()+" <http://sixdegreesoffrancisbacon.com/>");
 if (personInfo.odnb_id > 0){
  $("#node-DNBlink").attr("href", "http://www.oxforddnb.com/view/article/"+personInfo.odnb_id);
 }else{
  $("#node-DNBlink").attr("href", "http://www.oxforddnb.com/search/quick/?quicksearch=quicksearch&docPos=1&searchTarget=people&simpleName="+personInfo.first+"+"+personInfo.last);
 }
 $("#node-GoogleLink").attr("href", "http://www.google.com/search?q="+personInfo.first+"+"+ personInfo.last);
 $("#node-discussion").attr("href", "/people/" + personInfo.id);
 $("#node-icon-chain").attr("href", "/relationships/new?person1_id=" + personInfo.id);
 $("#node-icon-annotate").attr("href", "/user_person_contribs/new?person_id=" + personInfo.id);
}

/*
Num_rels Cluster    Color
 0-1		0        orange
 2-3		1        yellow
 4-5		2        aqua blue
 6-7		3        marine blue
 8-9		4        light blue
 10-11	5        hot pink
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

//creates a nodekey associative array with node info
function createNodeKey(node, id) {
  var nodeKey = {"text": node["display_name"], "size": 4, "id": id,  "cluster": 1};
  return nodeKey;
}

function twoDegs(id, id2, people, sconf, econf, sdate, edate) {
	var keys = {};
	var edges = [];
  var nodes = [];
	function createGraph(id, people, sconf, econf, sdate, edate) {
  	var p = people[id];
  	$.each(p.rel_sum, function(index, value) { 
  	  var q = value[0];
  		keys[q] = createNodeKey(people[q],q);
  		if (notInArray(edges, [id, value[0]])) {
  		 edges.push([id, value[0]]);
      }
      $.each(people[q].rel_sum, function(index, value1) { 
        var r = value1[0];
        if (r in people){
          keys[r] = createNodeKey(people[r],r);
          if (notInArray(edges, [value[0], value1[0]])) {
           edges.push([value[0], value1[0]]);
          }
        }
      });
    });
    //adds main person's id referenced to keys associative array. Keys represent all data in graph
    keys[id] = {"text": p["display_name"], "size": 20, "id": id,  "cluster": 1}; 
  }
  createGraph(id, people, sconf, econf, sdate, edate);
  if (id2 != 0 && id2 != ""){
      createGraph(id2, people, sconf, econf, sdate, edate);
  }
  $.each(keys, function(index, value) {
    nodes.push(value); //adds each key to nodes array
  });

    edges.reverse();
    var w = window.innerWidth;
    var h = window.innerHeight - $("#head").height() - $("#filterBar").height();
    var options = { width: w, height: h, collisionAlpha: 0.9, colors: getColorsRels() };
    var graph = new Insights($("#graph")[0], nodes, edges, options).render();
    graph.focus(id);
    graph.on("node:click", function(d) {
        var clicked = people[d.id];
        showNodeInfo(clicked);
    });
	
    graph.on("edge:click", function(d) {
        var id1 = parseInt(d.source.id);
        var id2 = parseInt(d.target.id);
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
function getAnnotation(id1, id2, people) {
  var id1_rel_array = people[id1].rels;
  var confidence = "";
  var rel_id = "";
  $.each(id1_rel_array, function(index, value) {                    
    if (value[0] == id2){
       confidence = getConfidence(value[1]) + " @ " + value[1] + "%";
       rel_id = value[3];
    }
  });
  accordion("edge");
  $("#edge-nodes").html(people[id1].display_name + " & " + people[id2].display_name);
  $("#edge-confidence").html(confidence);
  $("#edge-discussion").attr("href", "/relationships/" + rel_id );
  $("#edge-icon-annotate").attr("href", "/user_rel_contribs/new?relationship_id=" + rel_id );
  //$("#Sir-Mix-a-Lot").html(row.contributor); 
  return true;
};

function getParam ( sname ){
    var params = location.search.substr(location.search.indexOf("?")+1);
    var sval = "";
    params = params.split("&");
    // split param and value into individual pieces
    for (var i=0; i<params.length; i++){
        temp = params[i].split("=");
        if ( [temp[0]] == sname ) { 
            sval = temp[1]; 
        }
    }
    return sval;
}

function filterGraph(people){
    var ID = getParam("id");
    var ID2 = getParam("id2");
    var sconf = getParam("confidence").split(",")[0];
    var econf = getParam("confidence").split(",")[1];
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
    if(sconf == ""){
        sconf = default_sconfidence;
    }
    if(econf == ""){
        econf = default_econfidence;
    }
    twoDegs(ID, ID2, people, sconf, econf, sdate, edate);
}

function initGraph(people){
  var confidence = default_sconfidence + " to " + default_econfidence
  var date = default_sdate + " - " + default_edate
  if (getParam('id') > 0){
    var name = people[parseInt(getParam('id'))].display_name
  }else{
    var name = people[francisID].display_name
  }
  if (getParam('confidence').length > 0){
      confidence = getParam('confidence').replace(',', '% to ')
  }
  if (getParam('date').length > 0){
      date = getParam('date').replace(',', ' to ')
  }
  $("#results").html("Two degrees of " + name + " at " + confidence + "% from " + date);
  //click methods for all the 'find' buttons in the search bar
  //this should not use the entire peopletoarray instead it should use whatever value is passed through by the #one
  $("#search-network-submit").click(function () {
  	var table = 'no';
    Pace.restart();
    // make the index equal autocomplete
    var id = $("#search-network-name-id").val();
    if ($("#show-table").val() == 1) {
    	table = 'yes'
    }
    var confidence = $("#search-network-slider-confidence-result-hidden").val().split(" - ");
    var date = $("#search-network-slider-date-result-hidden").val().split(" - ");
    window.location.href = '/?id=' + id + '&confidence=' + confidence + '&date=' + date + '&table=' + table;
  });

   $("#search-shared-network-submit").click(function () {
      var table = 'no';
      Pace.restart();
      if ($("#search-shared-network-name1-id").val()) {
        var id1 = $("#search-shared-network-name1-id").val();
      }
      if ($("#search-shared-network-name2-id").val()) {
        var id2 = $("#search-shared-network-name2-id").val();
      }
      if ($("#show-table").val() == 1) {
        table = 'yes'
      }
      var confidence = $("#search-shared-network-slider-confidence-result-hidden").val().split(" - ");
      var date = $("#search-shared-network-slider-date-result-hidden").val().split(" - ");
      window.location.href = '/?id=' + id1 + '&id2=' + id2 + '&confidence=' + confidence + '&date=' + date + '&table=' + table;
    });

  $("#nav-filter-submit").click(function (){
    var ID = getParam("id");
    var confidence = $("#nav-slider-confidence-result-hidden").val().split(" - ");
    var date = $("#nav-slider-date-result").val().split(" - ");
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
	var data = { nodes: [], edges: [], groups_names: [], groups_desc: [], groups_people: []};
	var people = window.gon.people;
	var group_data = window.gon.group_data;
	//This function only converts gon to all data for the searched person and 1st degree relationships
 	/*$.each(people, function(index, value) { 
    var n = {}
  	n.id = value.id;
  	n.first = value.first_name;
  	n.last = value.last_name;
  	n.label = n.first + " " + n.last;
    n.display_name = value.display_name;
  	n.birth_year = value.ext_birth_year;
  	n.birth_year_type = value.birth_year_type;
  	n.death_year = value.ext_death_year;
  	n.death_year_type = value.death_year_type;
  	n.occupation = value.historical_significance;
  	n.rels = value.rel_sum;
  	n.size = n.rels.length;
  	n.odnb_id = value.odnb_id;
  	n.groups = value.group_list;
  	data.nodes[n.id] = n;
	});*/


  	//This function converts the gon for groups into readable information for groups
	$.each(group_data, function(index, value){
  	data.groups_names.push(value.name);
  	data.groups_desc.push(value.description);
  	data.groups_people.push(value.person_list);
	});
	filterGraph(people);
	initGraph(people);
}

$(document).ready(function() {
  init();
});      