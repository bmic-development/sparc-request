$('#welcome_message').html("<%= escape_javascript render :partial => 'catalogs/description', :locals => {:organization => @organization} %>")
$('.core-accordion').accordion({autoHeight: false, collapsible: true})
