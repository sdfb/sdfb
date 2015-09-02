var francisID = 10000473;
var default_sconfidence = 60;
var default_econfidence = 100;
var default_sdate = 1500;
var default_edate = 1700;
  
/*
Num_rels Cluster    Color
 0      0        grey
 1-4    1        red
 5-9    2        orange
 10-19  3        yellow
 20-29  4        light blue
 30-49  5        medium blue
 50+    6        dark blue
*/


//returns cluster number based on number of relationships the cluster has
 function getClusterRels(node){
   try{
     var size = Object.keys(node).length;
   }
   catch(err) {
     var size = 0;
   }
 };

//returns cluster number based on number of relationships the cluster has

function getClusterRels(node){
  try{
    var size = Object.keys(node).length;
  }
  catch(err) {
    var size = 0;
  }

   if (size >= 50){
     return 6;
   } else if (size >= 30){
     return 5;
   } else if (size >= 20) {
     return 4;
   } else if (size >=10) {
     return 3;
   } else if (size >=5) {
     return 2;
   } else if (size >=1) {
     return 1;
   } else {
     return 0;
   }
 }

// //returns colors based on cluster group number
 function getColorsRels(){
    return { 0: "#bdbdbd", 1: "#d73027", 2: "#f46d43", 3: "#fdae61", 4: "#abd9e9", 5: "#74add1", 6: "#4575b4"}
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
  return {"text": node["display_name"], "size": 10, "id": id,  "cluster": getClusterRels(node["rel_sum"])};
}

function createEdgeKey(node1, node2) {
  var text = node1["display_name"] + " & " + node2["display_name"];
  return {"text": text };
}

function twoDegs(id, id2, people) {
  var keys = {};
  var edges = [];
  var nodes = [];

  function createGraph(id, people) {
    var p = people[id];
    $.each(p.rel_sum, function(index, value) { 
      var q = value[0];
      keys[q] = createNodeKey(people[q],q);
      if (notInArray(edges, [id, value[0]])) {
       edges.push([id, value[0]], createEdgeKey(p, people[q]));
      }
      $.each(people[q].rel_sum, function(index, value1) { 
        var r = value1[0];
        if (r in people){
          keys[r] = createNodeKey(people[r],r);
          if (notInArray(edges, [value[0], value1[0]])) {
           edges.push([value[0], value1[0]], createEdgeKey(people[q], people[r]));
          }
        }
      });
      console.log(edges);
    });
    //adds main person's id referenced to keys associative array. Keys represent all data in graph
    keys[id] = {"text": p["display_name"], "size": 30, "id": id,  "cluster": getClusterRels(p["rel_sum"])}; 
  }

  createGraph(id, people);
  if (id2 != 0 && id2 != ""){
      createGraph(id2, people);
      keys[id2] = {"text": people[id2]["display_name"], "size": 30, "id": id2,  "cluster": getClusterRels(people[id2]["rel_sum"])};
      keys[id] = {"text": people[id]["display_name"], "size": 30, "id": id,  "cluster": getClusterRels(people[id]["rel_sum"])};
  }
  $.each(keys, function(index, value) {
    nodes.push(value); //adds each key to nodes array
  });

    edges.reverse();
    var w = window.innerWidth;
    var h = window.innerHeight;
    var options = { width: w, height: h, collisionAlpha: 25, colors: getColorsRels() };
    var graph = new Insights($("#graph")[0], nodes, edges, options).render();

    graph.on("node:click", function(d) {
      var clicked = people[d.id];
      $.ajax({
            type: "GET",
            url:    "/node_info", // should be mapped in routes.rb
            data: {node_id:d.id},
            datatype:"html", // check more option
            success: function(data) {
                     // handle response data
                     },
            async:   true
          });  
      accordion("node");
    });

    graph.on("node:dblclick", function(d) {
      var table = 'no';
      Pace.restart();
      // make the index equal autocomplete
      var id = d.id;
      if ($("#show-table").val() == 1) {
        table = 'yes'
      }
      var sconf = getParam('confidence').split(',')[0];
      var econf = getParam('confidence').split(',')[1];
      var sdate = getParam('date').split(',')[0];
      var edate = getParam('date').split(',')[1];
      if (id  && sconf && econf && sdate && edate ) {
        window.location.href = '/?id=' + id + '&confidence=' + sconf + ',' + econf + ',&date=' + sdate + ',' + edate;
      }
    });
  
    graph.on("edge:click", function(d) {
        var id1 = parseInt(d.source.id);
        var id2 = parseInt(d.target.id);
        $.ajax({
            type: "GET",
            url:    "/network_info", // should be mapped in routes.rb
            data: {source_id:d.source.id, target_id:d.target.id},
            datatype:"html", // check more option
            success: function(data) {
                     // handle response data
                     },
            async:   true
          });  
        accordion("edge");
    });


    graph.tooltip("<div class='btn' >"+"{{text}}" + "</div>");
  
    

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
        return "Very Unlikely";}
    else if (20 <= n &&  n<= 39) {
        return "Unlikely";}
    else if (40 <= n &&  n<= 59) {
        return "Possible";}
    else if (60 <= n && n<= 79) {
        return "Likely";}
    else {
        return "Certain";}
}

function getParam ( sname ){
    var params = location.search.substr(location.search.indexOf("?")+1);
    var sval = "";
    params = params.split("&");
    // split param and value into individual pieces
    //$("#Sir-Mix-a-Lot").html(row.contributor); 
    for (var i=0; i<params.length; i++){
        temp = params[i].split("=");
        if ( [temp[0]] == sname ) { 
            sval = temp[1]; 
        }
    }
    return sval;
}

function showAccordion(id, id2){
  if (id2 == "0"){
    $.ajax({
          type: "GET",
          url:    "/node_info", // should be mapped in routes.rb
          data: {node_id:id},
          datatype:"html", // check more option
          success: function(data) {
                   // handle response data
                   },
          async:   true
        });  
      accordion("node");
  }
  
}

function filterGraph(people){
    var ID = getParam("id");
    var ID2 = getParam("id2");
    if(ID2 == "" || ID2 == "0"){
        ID2 = 0;
    } 
    if(ID == ""){
        ID = francisID;
    }
    twoDegs(ID, ID2, people);
    showAccordion(ID, ID2);
}

function initGraph(people){
  var confidence = default_sconfidence + " to " + default_econfidence
  var date = default_sdate + " - " + default_edate
  if (getParam('id') > 0){
    var name = people[parseInt(getParam('id'))].display_name
  }else{
    var name = people[francisID].display_name
  }
  if (getParam('id2') > 0){
    var name2 = " and " + people[parseInt(getParam('id2'))].display_name
  }else{
    var name2 = ""
  }
  if (getParam('confidence').length > 0){
      confidence = getParam('confidence').replace(',', '% to ').replace(',', '');
  }
  if (getParam('date').length > 0){
      date = getParam('date').replace(',', ' to ')
  }
  $("#results").html("Two Degrees of " + name + name2 + " at " + confidence + "% from " + date + " (100 node display limit)");
  //click methods for all the 'find' buttons in the search bar
  //this should not use the entire peopletoarray instead it should use whatever value is passed through by the #one
}

function sidebarSearch(people){
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
    if (id  && confidence && date ){
      window.location.href = '/?id=' + id + '&confidence=' + confidence + '&date=' + date;
    }
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
      if (id1 && id2 && date && confidence){
        window.location.href = '/?id=' + id1 + '&id2=' + id2 + '&confidence=' + confidence + '&date=' + date + '&table=' + table;
      }    
    });

  $("#search-group-submit").click(function () {
    Pace.restart();
    // make the index equal autocomplete
    var id = $("#search-group-name-id").val();
    if (id ){
      window.location.href = '/?group=' + id;
    }
  });

  $("#search-shared-group-submit").click(function () {
    Pace.restart();
    // make the index equal autocomplete
    var id1 = $("#search-shared-group-name1-id").val();
    var id2 = $("#search-shared-group-name2-id").val();
    if (id1 && id2){
      window.location.href = '/?group=' + id1 + '&group2=' + id2;
    }  
  });

  $("#nav-filter-submit").click(function (){
    var ID = getParam("id");
    var ID2 = getParam("id2")
    if (ID2 != ""){
      ID2Str = "&id2=" + ID2
    }
    else{
      ID2Str = ""
    }
    var confidence = $("#nav-slider-confidence-result-hidden").val().split(" - ");
    var date = $("#nav-slider-date-result-hidden").val().split(" - ");
    if ( ID != ""){
      window.location.href = '/?id=' + ID + ID2Str + '&confidence=' + confidence + '&date=' + date;
    }
    if (ID == ""){
      window.location.href = '/?id=' + francisID + ID2Str + '&confidence=' + confidence + '&date=' + date;  
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
  var people = window.gon.people;
  var group_data = window.gon.group_data;
  var group = window.gon.group;
  var group2 = window.gon.group2;
  var group_members = window.gon.group_members;
  sidebarSearch(people);
  if (people != undefined){
    if (people[0] == "nodelimit"){
      console.log("node limit reached")
      $("#group-table").hide();
      $("#kickback").show();
      $('#kickbackyes').attr('href', "/people_relationships?id=" + people[1]);
      $( "#kickbackno" ).click(function() {
        $("#kickback").hide();
        $("#search-network-name").val(people[2][0]["display_name"]);
        $("#search-network-name" ).click();
        $("#search-network-name-id").val(people[1]);
        $("#search-button").click();
      });
    }
    
    if (people[0] == "nodelimit_network"){
      console.log("network");
      $("#group-table").hide();
      $("#kickback").show();
      $('#kickbackyes').hide();
      $("#kickbackno" ).click(function() {
        $("#kickback").hide();
        $("#search-shared-network-name1").val(people[4][0]["display_name"]);
        $("#search-shared-network-name1" ).click();
        $("#search-shared-network-name1-id").val(people[2]);    
        $("#search-shared-network-name2").val(people[5][0]["display_name"]);
        $("#search-shared-network-name2" ).click();
        $("#search-shared-network-name2-id").val(people[3]);                    
        $("#search-button" ).click();
        $("#search-shared-network").click();
      });
    }
  }

  if (getParam("group").length == 0){
    filterGraph(people);
    initGraph(people);
    $('#group-table').hide();
  }else{
     accordion("group");  
    $("#filterBar").hide();
    $("#group-name").text(group["name"]);
    $("#group-description").text(group["description"]);
    $("#group-discussion").attr("href", "groups/" + group["id"])
    $("#group-icon-annotate").attr("href", "/user_group_contribs/new?group_id=" + group["id"]);
    $("#group-icon-tag").attr("href", "/group_assignments/new?group_id=" + group["id"]);
    $(".group2").hide();
    if (typeof group2 != 'undefined'){
      $("#group-name2").text(group2["name"]);
      $("#group-description2").text(group2["description"]);
      $("#group-discussion2").attr("href", "groups/" + group2["id"])
      $(".group2").show();
      $("#group-icon-annotate2").attr("href", "/user_group_contribs/new?group_id=" + group2["id"]);
      $("#group-icon-tag2").attr("href", "/group_assignments/new?group_id=" + group2["id"]);
    }
    $.each(group_members, function(index, value) { 
      $( "#group-table" ).append( "<div class='group-row'><div class='col-md'>" + group_members[index]["display_name"] + "</div><div class='col-md'>" + group_members[index]["ext_birth_year"] + "</div><div class='col-md'>" + group_members[index]["ext_death_year"] + "</div><div class='col-md'><a href='/people/" + group_members[index]["id"] + "'>" + + group_members[index]["id"] + "</a></div></div>");
    });
  }
}

$(document).ready(function() {
  init();  

});      