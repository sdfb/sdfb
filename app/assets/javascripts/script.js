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
    //min/max of all sliders
    var default_sdate = 1500
    var default_edate = 1700
    var default_sconfidence = 0
    var default_econfidence = 100
    var range_default_certainty = [60,100]
    var range_default_date = [1500, 1700]
    if (getParam('confidence').length > 0){
      range_default_certainty= getParam('confidence').split(',');   
    }
    if (getParam('date').length > 0){
       range_default_date = getParam('date').split(','); 
    }

    //populate all date and certainty fields intitially

    $("#search-network-slider-confidence-sinput").val(range_default_certainty[0]);
    $("#search-network-slider-confidence-einput").val(range_default_certainty[1]);
    $("#search-network-slider-confidence-result-hidden").val(range_default_certainty[0] + " - " + range_default_certainty[1]);    
    $("#search-network-slider-date-sinput").val(range_default_date[0]);
    $("#search-network-slider-date-einput").val(range_default_date[1]);
    $("#search-network-slider-date-result-hidden").val(range_default_date[0] + " - " + range_default_date[1]);       

    $("#search-shared-network-slider-confidence-sinput").val(range_default_certainty[0]);
    $("#search-shared-network-slider-confidence-einput").val(range_default_certainty[1]);
    $("#search-shared-network-slider-confidence-result-hidden").val(range_default_certainty[0] + " - " + range_default_certainty[1]);    
    $("#search-shared-network-slider-date-sinput").val(range_default_date[0]);
    $("#search-shared-network-slider-date-einput").val(range_default_date[1]);  
    $("#search-shared-network-slider-date-result-hidden").val(range_default_date[0] + " - " + range_default_date[1]);        

    $("#nav-slider-confidence-sinput").val(range_default_certainty[0]);
    $("#nav-slider-confidence-einput").val(range_default_certainty[1]);
    $("#nav-slider-confidence-result-hidden").val(range_default_certainty[0] + " - " + range_default_certainty[1]);    
    $("#nav-slider-date-sinput").val(range_default_date[0]);
    $("#nav-slider-date-einput").val(range_default_date[1]);  
    $("#nav-slider-date-result-hidden").val(range_default_date[0] + " - " + range_default_date[1]);  

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
    $("#contribute-add-new").tooltip({placement: 'right', title: 'Check out our new way of contributing to the database!'});

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
    // $("#edge-annotate").tooltip({placement: 'right', title: 'These percentages were inferred by statistically analyzing the Oxford Dictionary of National Biography. Click for more information.'});
    $("#edge-annotate").tooltip({placement: 'right', title: 'The average confidence is calculated for each relationship type. The maximum of those averages is the Max Confidence.'});
    $("#group-icon-label").tooltip({placement: 'right', title: 'Add person to group'});
    $("#group-icon-annotate").tooltip({placement: 'right', title: 'Add a note to this group'});

    $(".icon-zoomin").tooltip({placement:  'left', title: 'Zoom In'});
    $(".icon-zoomout").tooltip({placement:  'left', title: 'Zoom Out'});
	$(".icon-info").tooltip({placement:  'left', title: 'Scroll to zoom, click on node or edge for more information, click background to reset view'});

    $("#search-network-slider-confidence").tooltip({placement: 'right', title: 'Choose the Confidence Level'});
    $("#search-network-slider-date").tooltip({placement: 'right', title: 'Choose the Date Range'});

    $("#search-shared-network-slider-confidence").tooltip({placement: 'right', title: 'Choose the Confidence Level'});
    $("#search-shared-network-slider-date").tooltip({placement: 'right', title: 'Choose the Date Range'});

    $("#nav-slider-confidence").tooltip({placement: 'right', title: 'Choose the Confidence Level, then Click Filter'});
    $("#nav-slider-date").tooltip({placement: 'right', title: 'Choose the Date Range, then Click Filter'});

    //Add a Person Page
    $("#person_display_name").tooltip({placement: 'right', title: 'This is the name that will be displayed in the network visualization. It will be automatically generated from the first and last name if you leave this field blank.'});
    $("#person_prefix").tooltip({placement: 'right', title: 'Bishop, King, Queen, Sir, etc.'});
    $("#person_first_name").tooltip({placement: 'right', title: 'First name.'});
    $("#person_last_name").tooltip({placement: 'right', title: 'Last/Surname.'});
    $("#person_suffix").tooltip({placement: 'right', title: 'the Elder, III, of Rires, etc.'});
    $("#person_title").tooltip({placement: 'right', title: 'Archbishop of Canterbury, King/Queen of England, etc.'});
    $("#person_gender").tooltip({placement: 'right', title: 'Please only use the "gender_nonconforming" category to indicate people who - historically - did not identify with a binary gender, rather than people who modern scholars would not identify as female or male.'});
    $("#person_odnb_id").tooltip({placement: 'right', title: 'For people with biographies in the Oxford Dictionary of National Biography.  Their ID can be found at the bottom of their biography or in the URL as the number XXXXX at the end of the URL http://www.oxforddnb.com/ view/article/XXXXX.'});
    $("#person_birth_year_type").tooltip({placement: 'right', title: 'BF = Before, AF = After, IN = In, CA = Circa, BF/IN = Before or In, AF/IN = After or In'});
    $("#person_ext_birth_year").tooltip({placement: 'right', title: 'Either the estimated birth year or the earliest possible birth year for a person.  I.e. 1540 for a person born in January 1540/1 or 1607 for a person born between 1607 and 1610.'});
    $("#person_alt_birth_year").tooltip({placement: 'right', title: 'Either an alternative birth year or the latest possible birth year for a person.  I.e. 1541 for a person born in January 1540/1 or 1610 for a person born between 1607 and 1610.'});
    $("#person_death_year_type").tooltip({placement: 'right', title: 'BF = Before, AF = After, IN = In, CA = Circa, BF/IN = Before or In, AF/IN = After or In'});    
    $("#person_ext_death_year").tooltip({placement: 'right', title: 'Either the estimated death year or the earliest possible death year for a person.  I.e. 1540 for a person who died in January 1540/1 or 1607 for a person who died between 1607 and 1610.'});
    $("#person_alt_death_year").tooltip({placement: 'right', title: 'Either an alternative death year or the latest possible death year for a person.  I.e. 1541 for a person who died in January 1540/1 or 1610 for a person who died between 1607 and 1610.'});
    $("#person_historical_significance").tooltip({placement: 'right', title: 'Generally the person\'s title, occupation, or most important relationships.'});
    $("#person_justification").tooltip({placement: 'right', title: 'Why this person should be added to the SDFB database.'}); 
    $("#person_bibliography").tooltip({placement: 'right', title: 'Citation for information, if appropriate.'});            

    //User Person Contribs
    $("#user_person_contrib_person_autocomplete").tooltip({placement: 'right', title: 'Please type the beginning of the person\'s name, then select them from the autocomplete list once they appear.'});
    $("#user_person_contrib_annotation").tooltip({placement: 'right', title: 'Information/comment you wish to add to the person\'s entry.'});
    $("#user_person_contrib_bibliography").tooltip({placement: 'right', title: 'Citation for information, if appropriate.'});    

    //new Relationships Page
    $("#relationship_person1_autocomplete").tooltip({placement: 'right', title: 'Please type the beginning of the person\'s name, then select them from the autocomplete list once they appear.'});
    $("#relationship_person2_autocomplete").tooltip({placement: 'right', title: 'Please type the beginning of the person\'s name, then select them from the autocomplete list once they appear.'});
    $(".relationship_confidence").tooltip({placement: 'right', title: 'Please move the slider as appropriate to indicate your estimated confidence for the relationship.  80-100 is certain; 60-80 is very likely; 40-60 is possible; 20-40 is unlikely; 0-20 is very unlikely.'});
    $("#relationship_start_date_type").tooltip({placement: 'right', title: 'BF = Before, AF = After, IN = In, CA = Circa, BF/IN = Before or In, AF/IN = After or In'});    
    $("#relationship_start_year").tooltip({placement: 'right', title: 'If you leave this field blank, the approximate start date will be automatically generated from the later of the two birth dates of the people in the relationship.'});
    $("#relationship_end_date_type").tooltip({placement: 'right', title: 'BF = Before, AF = After, IN = In, CA = Circa, BF/IN = Before or In, AF/IN = After or In'});
    $("#relationship_end_year").tooltip({placement: 'right', title: 'If you leave this field blank, the approximate end date will be automatically generated from the earlier of the two death dates of the people in the relationship.'});
    $("#relationship_justification").tooltip({placement: 'right', title: 'Why this relationship should be added to the SDFB database.'});    
    $("#relationship_bibliography").tooltip({placement: 'right', title: 'Citation for information, if appropriate.'});                     

    //relationship type assignments
    $("#user_rel_contrib_person1_autocomplete").tooltip({placement: 'right', title: 'Please type the beginning of the person\'s name, then select them from the autocomplete list once they appear.'});
    $("#user_rel_contrib_relationship_type_id").tooltip({placement: 'right', title: 'Please select the appropriate relationship type.  For directional relationships, read as \'Person 1 is xxxx of Person 2.\'  For full relationship type definitions, please use the \'View Records\' dropdown menu to visit the Relationship Types index page.'});
    $("#user_rel_contrib_person2_autocomplete").tooltip({placement: 'right', title: 'Please type the beginning of the person\'s name, then select them from the autocomplete list once they appear.'});
    $(".user_rel_contrib_confidence").tooltip({placement: 'right', title: 'Please move the slider as appropriate to indicate your estimated confidence for the relationship.  80-100 is certain; 60-80 is very likely; 40-60 is possible; 20-40 is unlikely; 0-20 is very unlikely.'});
    $("#user_rel_contrib_start_date_type").tooltip({placement: 'right', title: 'BF = Before, AF = After, IN = In, CA = Circa, BF/IN = Before or In, AF/IN = After or In'});
    $("#user_rel_contrib_start_year").tooltip({placement: 'right', title: 'If you leave this field blank, the approximate start date will be automatically generated from the later of the two birth dates of the people in the relationship.'});
    $("#user_rel_contrib_end_date_type").tooltip({placement: 'right', title: 'BF = Before, AF = After, IN = In, CA = Circa, BF/IN = Before or In, AF/IN = After or In'});
    $("#user_rel_contrib_end_year").tooltip({placement: 'right', title: 'If you leave this field blank, the approximate end date will be automatically generated from the earlier of the two death dates of the people in the relationship.'});
    $("#user_rel_contrib_annotation").tooltip({placement: 'right', title: 'Why this relationship type information should be added to the SDFB database.'});
    $("#user_rel_contrib_bibliography").tooltip({placement: 'right', title: 'Citation for information, if appropriate.'});        


    //new group
    $("#group_name").tooltip({placement: 'right', title: 'Name of group.'});
    $("#group_description").tooltip({placement: 'right', title: 'Description of group, including membership criteria if relevant.'});
    $("#group_start_date_type").tooltip({placement: 'right', title: 'BF = Before, AF = After, IN = In, CA = Circa, BF/IN = Before or In, AF/IN = After or In'});
    $("#group_start_year").tooltip({placement: 'right', title: 'If you leave this field blank, the approximate start date will be automatically generated as 1500.'});
    $("#group_end_date_type").tooltip({placement: 'right', title: 'BF = Before, AF = After, IN = In, CA = Circa, BF/IN = Before or In, AF/IN = After or In'});
    $("#group_end_year").tooltip({placement: 'right', title: 'If you leave this field blank, the approximate start date will be automatically generated as 1700.'});     
    $("#group_justification").tooltip({placement: 'right', title: 'Why this group should be added to the SDFB database.'});   
    $("#group_bibliography").tooltip({placement: 'right', title: 'Citation for information, if appropriate.'});                    

    //new group assignment
    $("#group_assignment_group_id").tooltip({placement: 'right', title: 'Please select the appropriate group from the drop-down menu.'});
    $("#group_assignment_person_autocomplete").tooltip({placement: 'right', title: 'Please type the beginning of the person\'s name, then select them from the autocomplete list once they appear.'});    
    $("#group_assignment_start_date_type").tooltip({placement: 'right', title: 'BF = Before, AF = After, IN = In, CA = Circa, BF/IN = Before or In, AF/IN = After or In'});
    $("#group_assignment_start_year").tooltip({placement: 'right', title: 'If you leave this field blank, the approximate start date will be automatically generated from the later of the person\'s birth date and the group\'s start date.'});    
    $("#group_assignment_end_date_type").tooltip({placement: 'right', title: 'BF = Before, AF = After, IN = In, CA = Circa, BF/IN = Before or In, AF/IN = After or In'});
    $("#group_assignment_end_year").tooltip({placement: 'right', title: 'If you leave this field blank, the approximate end date will be automatically generated from the earlier of the person\'s death date and the group\'s end date.'});            
	$("#group_assignment_annotation").tooltip({placement: 'right', title: 'Why this group assignment should be added to the SDFB database.'}); 
	$("#group_assignment_bibliography").tooltip({placement: 'right', title: 'Citation for information, if appropriate.'}); 	           

    //group note
    $("#user_group_contrib_group_id").tooltip({placement: 'right', title: 'Please select the appropriate group from the drop-down menu.'});
    $("#user_group_contrib_annotation").tooltip({placement: 'right', title: 'Information/comment you wish to add to the group\'s entry.'});    
    $("#user_group_contrib_bibliography").tooltip({placement: 'right', title: 'Citation for information, if appropriate.'});    

    //user information
    $("#user_prefix").tooltip({placement: 'right', title: 'Sir, Dr., etc.'});
    $("#user_first_name").tooltip({placement: 'right', title: 'First name.'});
    $("#user_last_name").tooltip({placement: 'right', title: 'Last/Surname.'});
    $("#user_username").tooltip({placement: 'right', title: 'Note: this information may be viewable by other registered users.'});
    $("#user_email").tooltip({placement: 'right', title: 'This email address will be used for logging into the website and for resetting your password if necessary.'});
    $("#user_password").tooltip({placement: 'right', title: 'Your password must include at least one number, at least one letter, and at least 7 characters.'});
    $("#user_password_confirmation").tooltip({placement: 'right', title: 'Your password must include at least one number, at least one letter, and at least 7 characters.'});
    $("#user_orcid").tooltip({placement: 'right', title: 'Unique researcher identifier from http://orcid.org.'});
    $("#user_affiliation").tooltip({placement: 'right', title: 'Institutional affiliation, if appropriate.'});
    $("#user_about_description").tooltip({placement: 'right', title: 'Note: this information may be viewable by other registered users.'});  


	$('#search-network-form').css('display','block');

    $("#search-network-show-table").click(function(){
        $("#search-network-show-table").attr('href', "/people/" + $("#search-network-name-id").val());
    });

    $("#relationship-type").click(function(){
        $(".relationship-type-sort").show();
        $(".relationship-confidence-sort").hide();
    });

    $("#relationship-confidence").click(function(){
        $(".relationship-type-sort").hide();
        $(".relationship-confidence-sort").show();
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
        values: range_default_date,
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
        value: range_default_certainty[0],
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
        values: range_default_date,
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
        values: range_default_certainty,
        // Gets a live reading of the value and prints it on the page
        slide: function( event, ui ) {
            var sresult = getConfidence(ui.values[0]);
            var eresult = getConfidence(ui.values[1]);
            $("#nav-slider-confidence-sinput").val(ui.values[0]);
            $("#nav-slider-confidence-einput").val(ui.values[1]);            
            $("#nav-slider-confidence-result-hidden").val(ui.values[0] + " - " + ui.values[1]);
            $("#nav-slider-confidence-result").html( sresult + " to " + eresult);

        }
    });

    $("#nav-slider-confidence-sinput").change(function(){
        var range = $("#nav-slider-confidence").slider( "values");
        if ($(this).val() < range[1] && $(this).val() >= default_sconfidence){
            $("#nav-slider-confidence").slider( "option", "values", [$(this).val(), range[1]]);
            $("#nav-slider-confidence-result-hidden").val($(this).val() + " - " + range[1]);
            var eresult = getConfidence(range[1]);
            var sresult = getConfidence($(this).val());
            $("#nav-slider-confidence-result").html( sresult + " to " + eresult);
        }else{
            $(this).val(range[0]);
        }
    });          

    $("#nav-slider-confidence-einput").change(function(){
        var range = $("#nav-slider-confidence").slider( "values");
        if ($(this).val() > range[0] && $(this).val() <= default_econfidence){
            $("#nav-slider-confidence").slider( "option", "values", [range[0], $(this).val()]);
            $("#nav-slider-confidence-result-hidden").val(range[0]+ " - " + $(this).val());
            var sresult = getConfidence(range[0]);
            var eresult = getConfidence($(this).val());
            $("#nav-slider-confidence-result").html( sresult + " to " + eresult);
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
        values: range_default_date,
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

    $("#nav-slider p").click(function(){
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