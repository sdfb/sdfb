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

$(document).ready(function() {

    var default_sdate = 1500
    var default_edate = 1700
    var default_certainty = 60
    var range_default_certainty = [60,100]
    var default_sconfidence = 0
    var default_econfidence = 100


     $("#colorlegend").dialog({autoOpen: false, height: "auto", show: "slideDown", position: { my: "right top", at: "right-10% top+10%", of: window }});
     $(".ui-dialog-titlebar-close").html("X");

    //Tooltips
	$("#search-network").tooltip({placement: 	'right', title: 'First- and second-degree network connections of one person'});
    $("#search-shared-network").tooltip({placement:     'left', title: 'First- and second-degree network connections shared by two people'});
	$("#search-group").tooltip({placement: 	'right', title: 'Members belonging to a group'});
    $("#search-shared-group").tooltip({placement:   'left', title: 'Members belonging to both groups'});

    $("#contribute-add-person").tooltip({placement:   'right', title: 'Add a new person to the database'});
    $("#contribute-add-group").tooltip({placement:  'right', title: 'Add a new group to the database'});
    $("#contribute-add-relationship").tooltip({placement:   'right', title: 'Add a new, untyped relationship between two people in the database'});

    $("#icon-tag").tooltip({placement:  'right', title: 'Tag group'});
    $("#icon-link").tooltip({placement: 'right', title: 'Add a new, untyped relationship for this person'});
    $("#icon-annotate").tooltip({placement: 'right', title: 'Add a note to this relationship'});

    $("#icon-color").click(function() {
      $( "#colorlegend" ).dialog( "open" );
    });

    $("#node-icon-tag").tooltip({placement:  'right', title: 'Add person to a group'});
    $("#group-icon-tag").tooltip({placement:  'right', title: 'Add a person to this group'});
    $("#group-icon-tag2").tooltip({placement:  'right', title: 'Add a person to this group'});
    $("#node-icon-chain").tooltip({placement: 'right', title: 'Add a new, untyped relationship for this person'});
    $("#node-icon-annotate").tooltip({placement: 'right', title: 'Add a note to this person'});
    $("#group-icon-annotate").tooltip({placement: 'right', title: 'Add a note to this group'});
    $("#group-icon-annotate2").tooltip({placement: 'right', title: 'Add a note to this group'});
    $("#edge-icon-annotate").tooltip({placement: 'right', title: 'Add a relationship type and note to this relationship'});
    $("#group-icon-label").tooltip({placement: 'right', title: 'Add person to group'});
    $("#group-icon-annotate").tooltip({placement: 'right', title: 'Add a note to this group'});

    $(".icon-zoomin").tooltip({placement:  'left', title: 'Zoom In'});
    $(".icon-zoomout").tooltip({placement:  'left', title: 'Zoom Out'});
	$(".icon-info").tooltip({placement:  'left', title: 'Scroll to zoom, double click on node or edge for more information, single click to reset view'});

    $("#search-network-slider-confidence").tooltip({placement: 'right', title: 'Choose the Confidence Level'});
    $("#search-network-slider-date").tooltip({placement: 'right', title: 'Choose the Date Range'});

    $("#search-shared-network-slider-confidence").tooltip({placement: 'right', title: 'Choose the Confidence Level'});
    $("#search-shared-network-slider-date").tooltip({placement: 'right', title: 'Choose the Date Range'});

    $("#nav-slider-confidence").tooltip({placement: 'right', title: 'Choose the Confidence Level, then Click Filter'});
    $("#nav-slider-date").tooltip({placement: 'right', title: 'Choose the Date Range, then Click Filter'});

	$('#search-network-form').css('display','block');

    $("#search-network-show-table").click(function(){
        $("#search-network-show-table").attr('href', "/people/" + $("#search-network-name-id").val());
    });

    // Color guide
    // $("#icon-color").click(function(){
    //     if( $('#guide').css('display') == 'none' ){
    //         $("#guide").css('display','block');
    //     }
    //     else{
    //         $("#guide").css('display','none');
    //     }        
    // });
    // $("#guide").click(function(){
    //       $("#guide").css('display','none');
    // });

	// Shows search bars when click on side menu
	$('.accordion_content ul li').click(function(e){
        $('.accordion_content ul li').removeClass('clicked');
        $(this).addClass('clicked');
		$('section').css('display','none');	
		var id = '#' + e.target.id + '-form';
		$(id).css('display','block');
	});
	$('.toggle').click(function(e){
		$('.toggle').removeClass('active');
		$(this).addClass('active');
	});
	$('#search-shared-group').click(function(e){
		$('#search-shared-group-form').css('display','block');
	});
    $('section button').click(function(e){
        if (this.name == "node") {
            $('#zoom').css('display','block');
        } else if (this.name == "group") {
            $('#zoom').css('display','none');
        }
    });
    $("aside button.icon").click(function(e){
        $('.accordion_content ul li').removeClass('clicked');
        $('section').css('display','none');
        $('#add' + this.name).addClass('clicked');
        $('#add'+ this.name + 'form').css('display','block');
        $('#accordion h3').removeClass('on');
        $('#accordion div').slideUp();
        $('#contribute').prev().addClass('on');
        $('#contribute').slideDown();
    });

 //  Sliding animation
	$("#search-network-slider-confidence").slider({
        animate: true,
        range: true,
        min: default_sconfidence,
        max: default_econfidence,
        step: 1,
        values: range_default_certainty,
        // Gets a live reading of the value and prints it on the page
        slide: function( event, ui ) {
        	var sresult = getConfidence(ui.values[0]);
            var eresult = getConfidence(ui.values[1]);
            $("#search-network-slider-confidence-result").html( sresult + " to " + eresult);
            $("#search-network-slider-confidence-sinput").val(ui.values[0]);
            $("#search-network-slider-confidence-einput").val(ui.values[1]);
            $("#search-network-slider-confidence-result-hidden").val(ui.values[0] + " - " + ui.values[1]);
        }
    });

    $("#search-network-slider-confidence-sinput").change(function(){
        var range = $("#search-network-slider-confidence").slider( "values");
        if ($(this).val() < range[1] && $(this).val() >= default_sconfidence ){
            $("#search-network-slider-confidence").slider( "option", "values", [$(this).val(), range[1]]);
            $("#search-network-slider-confidence-result-hidden").val($(this).val() + " - " + range[1]);
            var sresult = getConfidence($(this).val());
            var eresult = getConfidence(range[1]);
            $("#search-network-slider-confidence-result").html( sresult + " to " + eresult);
        }else{
            $(this).val(range[0]);
        }
    });

    $("#search-network-slider-confidence-einput").change(function(){
        var range = $("#search-network-slider-confidence").slider( "values");
        if ($(this).val() > range[0] && $(this).val() <= default_econfidence ){
            $("#search-network-slider-confidence").slider( "option", "values", [range[0], $(this).val()]);
            $("#search-network-slider-confidence-result-hidden").val(range[0]+ " - " + $(this).val());
            var sresult = getConfidence(range[0]);
            var eresult = getConfidence($(this).val());
            $("#search-network-slider-confidence-result").html( sresult + " to " + eresult);
        }else{
            $(this).val(range[1]);
        }
    });

    $("#search-network-slider-date").slider({
        animate: true,
        range: true,
        value: 3,
        min: default_sdate,
        max: default_edate,
        step: 1,
        values: [ default_sdate, default_edate ],
        slide: function( event, ui ) {
            $("#search-network-slider-date-sinput").val(ui.values[0]);
            $("#search-network-slider-date-einput").val(ui.values[1]);            
            $("#search-network-slider-date-result-hidden").val(ui.values[ 0 ] + " - " + ui.values[ 1 ]);
        }
    });

    $("#search-network-slider-date-sinput").change(function(){
        var range = $("#search-network-slider-date").slider( "values");
        if ($(this).val() < range[1] && $(this).val() >= default_sdate){
            $("#search-network-slider-date").slider( "option", "values", [$(this).val(), range[1]]);
            $("#search-network-slider-date-result-hidden").val($(this).val() + " - " + range[0]);
        }else{
            $(this).val(range[0]);
        }
    });          

    $("#search-network-slider-date-einput").change(function(){
        var range = $("#search-network-slider-date").slider( "values");
        if ($(this).val() > range[0] && $(this).val() <= default_edate){
            $("#search-network-slider-date").slider( "option", "values", [range[0], $(this).val()]);
            $("#search-network-slider-date-result-hidden").val(range[0]+ " - " + $(this).val());
        }else{
            $(this).val(range[1]);
        }
    });    

    //searches if enter is pressed
    $("#search-network-name").keyup(function(event){
        if(event.keyCode == 13){
            $("#search-network-submit").click();
        }
    });

    $("#search-shared-network-slider-confidence").slider({
        animate: true,
        range: true,
        value: default_certainty,
        min: default_sconfidence,
        max: default_econfidence,
        step: 1,
        values: range_default_certainty,
        // Gets a live reading of the value and prints it on the page
        slide: function( event, ui ) {
            var sresult = getConfidence(ui.values[0]);
            var eresult = getConfidence(ui.values[1]);
            $("#search-shared-network-slider-confidence-result").html( sresult + " to " + eresult);
            $("#search-shared-network-slider-confidence-sinput").val(ui.values[0]);
            $("#search-shared-network-slider-confidence-einput").val(ui.values[1]);
            $("#search-shared-network-slider-confidence-result-hidden").val(ui.values[0] + " - " + ui.values[1]);
        }
    });

    $("#search-shared-network-slider-confidence-sinput").change(function(){
        var range = $("#search-shared-network-slider-confidence").slider( "values");
        if ($(this).val() < range[1] && $(this).val() >= default_sconfidence){
            $("#search-shared-network-slider-confidence").slider( "option", "values", [$(this).val(), range[1]]);
            $("#search-shared-network-slider-confidence-result-hidden").val($(this).val() + " - " + range[1]);
            var sresult = getConfidence($(this).val());
            var eresult = getConfidence(range[1]);
            $("#search-shared-network-slider-confidence-result").html( sresult + " to " + eresult);
        }else{
            $(this).val(range[0]);
        }
    });

    $("#search-shared-network-slider-confidence-einput").change(function(){
        var range = $("#search-network-slider-confidence").slider( "values");
        if ($(this).val() > range[0] && $(this).val() <= default_econfidence){
            $("#search-shared-network-slider-confidence").slider( "option", "values", [range[0], $(this).val()]);
            $("#search-shared-network-slider-confidence-result-hidden").val(range[0]+ " - " + $(this).val());
            var sresult = getConfidence(range[0]);
            var eresult = getConfidence($(this).val());
            $("#search-shared-network-slider-confidence-result").html( sresult + " to " + eresult);
        }else{
            $(this).val(range[1]);
        }
    });    
	
    $("#search-shared-network-slider-date").slider({
        animate: true,
        range: true,
        value: 3,
        min: default_sdate,
        max: default_edate,
        step: 1,
        values: [ default_sdate, default_edate ],
        slide: function( event, ui ) {
            $("#search-shared-network-slider-date-sinput").val(ui.values[0]);
            $("#search-shared-network-slider-date-einput").val(ui.values[1]);    
            $("#search-shared-network-slider-date-result").html("Selected Years: ");
            $("#search-shared-network-slider-date-result-hidden").val(ui.values[ 0 ] + " - " + ui.values[ 1 ]);
        }
    });

    $("#search-shared-network-slider-date-sinput").change(function(){
        var range = $("#search-network-slider-date").slider( "values");
        if ($(this).val() < range[1] && $(this).val() >= default_sdate){
            $("#search-shared-network-slider-date").slider( "option", "values", [$(this).val(), range[1]]);
            $("#search-shared-network-slider-date-result-hidden").val($(this).val() + " - " + range[0]);
        }else{
            $(this).val(range[0]);
        }
    });          

    $("#search-shared-network-slider-date-einput").change(function(){
        var range = $("#search-network-slider-date").slider( "values");
        if ($(this).val() > range[0] && $(this).val() <= default_edate){
            $("#search-shared-network-slider-date").slider( "option", "values", [range[0], $(this).val()]);
            $("#search-shared-network-slider-date-result-hidden").val(range[0]+ " - " + $(this).val());
        }else{
            $(this).val(range[1]);
        }
    });        

    $("#search-shared-network-name1").keyup(function(event){
        if(event.keyCode == 13){
            $("#search-shared-network-submit").click();
        }
    });

    $("#search-shared-network-name2").keyup(function(event){
        if(event.keyCode == 13){
            $("#search-shared-network-submit").click();
        }
    });

    $("#nav-slider-confidence").slider({
        animate: true,
        range: true,
        value: 3,
        min: default_sconfidence,
        max: default_econfidence,
        step: 1,
        values: [default_sconfidence, default_econfidence],
        // Gets a live reading of the value and prints it on the page
        slide: function( event, ui ) {
            var sresult = getConfidence(ui.values[0]);
            var eresult = getConfidence(ui.values[1]);
            $("#nav-slider-confidence-sinput").val(ui.values[0]);
            $("#nav-slider-confidence-einput").val(ui.values[1]);            
            $("#nav-slider-confidence-result-hidden").val(ui.values[0] + " - " + ui.values[1]);
        }
    });

    $("#nav-slider-confidence-sinput").change(function(){
        var range = $("#nav-slider-confidence").slider( "values");
        if ($(this).val() < range[1] && $(this).val() >= default_sconfidence){
            $("#nav-slider-confidence").slider( "option", "values", [$(this).val(), range[1]]);
            $("#nav-slider-confidence-result-hidden").val($(this).val() + " - " + range[0]);
        }else{
            $(this).val(range[0]);
        }
    });          

    $("#nav-slider-confidence-einput").change(function(){
        var range = $("#nav-slider-confidence").slider( "values");
        if ($(this).val() > range[0] && $(this).val() <= default_econfidence){
            $("#nav-slider-confidence").slider( "option", "values", [range[0], $(this).val()]);
            $("#nav-slider-confidence-result-hidden").val(range[0]+ " - " + $(this).val());
        }else{
            $(this).val(range[1]);
        }
    });      

    //  Sliding animation
    $("#nav-slider-date").slider({
        animate: true,
        range: true,
        value: 3,
        min: default_sdate,
        max: default_edate,
        step: 1,
        values: [ default_sdate, default_edate],
        slide: function( event, ui ) {
            $("#nav-slider-date-sinput").val(ui.values[0]);
            $("#nav-slider-date-einput").val(ui.values[1]);
            $( "#nav-slider-date-result-hidden" ).val( ui.values[ 0 ] + " - " + ui.values[ 1 ] );
        }
    });

    $("#nav-slider-date-sinput").change(function(){
        var range = $("#nav-slider-date").slider( "values");
        if ($(this).val() < range[1] && $(this).val() >= default_sdate){
            $("#nav-slider-date").slider( "option", "values", [$(this).val(), range[1]]);
            $("#nav-slider-date-result-hidden").val($(this).val() + " - " + range[1]);
        }else{
            $(this).val(range[0]);
        }
    });          

    $("#nav-slider-date-einput").change(function(){
        var range = $("#nav-slider-date").slider( "values");
        if ($(this).val() > range[0] && $(this).val() <= default_edate){
            $("#nav-slider-date").slider( "option", "values", [range[0], $(this).val()]);
            $("#nav-slider-date-result-hidden").val(range[0]+ " - " + $(this).val());
        }else{
            $(this).val(range[1]);
        }
    });      

    $("#nav-anchor").click(function() {
        $("#nav-slider").toggleClass("nav-slider-show");
    });

    //This is for the slider in Rails to update the confidence based on the slider selection
    $("#slider1").change(function () {                    
    var newValue = $('#slider1').val();
    var result = "Very Unlikely";
        if (newValue > 19 && newValue < 40) {
                result = "Unlikely";
            } else if (newValue > 39 && newValue < 60) {
                result = "Possible";
            } else if (newValue > 59 && newValue < 80) {
                result = "Likely";
            } else if (newValue > 79){
            result = "Certain"
            }
            $("#formCertainty").html(result + " @ " + newValue + "%");
    });
});