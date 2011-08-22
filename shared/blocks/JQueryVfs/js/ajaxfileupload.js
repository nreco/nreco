;
(function ($) {
  $.ajaxUpload = {
    createUploadIframe: function(frameId)
    {
      var io = $('<iframe id="' + frameId + '" name="' + frameId + '" />');
      
 	  io.attr('src', jQuery.browser.opera ? 'javascript:void(0);' : 'javascript:false');
     io.css('position', 'absolute');
      io.css('top', '-1000px');
      io.css('left', '-1000px');

      io.appendTo(document.body);

      return io.get(0);
    },
    createUploadForm: function(formId, frameId, url, data)
    {
      //create form 
      var form = $('<form action="" target="' + frameId + '" method="POST" name="' + formId + '" id="' + formId + '" enctype="multipart/form-data"></form>'); 
      
      //set attributes
      form.attr('action', url)
          .attr('enctype', 'multipart/form-data')
          .attr('encoding', 'multipart/form-data')
          .css('position', 'absolute')
          .css('top', '-1200px')
          .css('left', '-1200px')
          .appendTo(document.body);
      
      $.each(data, function(name, val) {
          $('<input type="hidden" />').attr('name', name).attr('value', val).appendTo(form);
        });
      
      return form.get(0);
    }
  };
  
  $.fn.ajaxFileUpload = function(s) {
    s = $.extend({ }, $.ajaxSettings, s, 
                                      {
                                        contentType: 'multipart/form-data',
                                        cache: false,
                                        type: 'POST',
                                        async: true,
                                        username: null,
                                        password: null
                                      }); // Some forced options
      
    if ( s.data && s.processData && typeof s.data === "string" )
      throw "Can't use a string as data - sorry";
    
    var id = (new Date().getTime());
    var frameId = 'jUploadFrame' + id;
    var formId = 'jUploadForm' + id;    
    
    var io = $.ajaxUpload.createUploadIframe(frameId);
    var form = $.ajaxUpload.createUploadForm(formId, frameId, s.url, s.data);
    
    var oldElems = $(this);
    var newElems = oldElems.clone();
    
    oldElems.attr('id', '');
    
    $.each(oldElems, function(i) {
        $(oldElems[i]).before(newElems[i]);
      });
    
    oldElems.appendTo(form);   
  
    // Watch for a new set of requests
    if ( s.global && ! $.active++ )
      $.event.trigger( "ajaxStart" );
    
    var getDocument = function(io) {
        if (io.contentWindow)
          return io.contentWindow.document;
        else if (io.contentDocument)
          return io.contentDocument.document;
        
        return null;
      };
        
    // Create the request object
    var xml = {
                timeoutTimer: null,
                clearTimer: null,
                requestDone: false,
                
                getResponseHeader: function(str) {
                  if (str.toLowerCase() == 'content-type') {
                    try {
                      var doc = getDocument(io);
                      
                      // The firefox way
                      if (doc && doc.contentType)
                        return doc.contentType;
                    }
                    catch (ex) { }

                    //We have to guess...
                    if (s.dataType == 'xml' && this.responseXML && this.responseXML.documentElement && this.responseXML.documentElement.nodeName != 'HTML')
                      return 'text/xml';
                    
                    return 'text/html';
                  }
                  
                  throw "Unknown response header " + str;
                },
                getAllResponseHeaders: function() {
                  return [this.getResponseHeader('content-type')];
                },
                abort: function() {
                  if (this.clearTimer) return;
                  if (this.timeoutTimer) {
                    window.clearTimeout(this.timeoutTimer);
                    this.timeoutTimer = null;
                  }
                  
                  this.requestDone = true;
                  
                  // The request was completed
                  if( s.global )
                      $.event.trigger( "ajaxComplete", [xml, s] );

                  // Handle the global AJAX counter
                  if ( s.global && ! --$.active )
                      $.event.trigger( "ajaxStop" );
                  
                  var that = this;
                  
                  this.clearTimer = setTimeout(function() { 
                      try {
                        $(io).remove();
                        $(form).remove(); 
                      } 
                      catch(e) {
                        $.event.trigger("ajaxError", [xml, s]);
						//$.handleError(s, that, null, e);
                      }
                      finally {
                        that.clearTimer = null;
                      }
                    }, 100);
                }
              };
              
    if ( s.global )
        $.event.trigger("ajaxSend", [xml, s]);
    
    // Wait for a response to come back
    var uploadCallback = function(reason)
      {
        if (xml.requestDone) return;
        xml.requestDone = true;
        
        try {
          var doc = getDocument(io);
          
          if (doc) {
            if (doc.location.href != s.url && doc.location.href == 'about:blank') {
              throw "Bad HTTP status";
            }
            
            // IE is EVIL!
            if (doc.XMLDocument && s.dataType == 'xml')
              doc = doc.XMLDocument;
            
            if (s.dataType == 'html' && doc.documentElement && doc.documentElement.innerHTML)
              xml.responseText = doc.documentElement.innerHTML;
            else if (doc.documentElement && 
                      (doc.documentElement.textContent || doc.documentElement.innerText))
              xml.responseText = doc.documentElement.innerText ? doc.documentElement.innerText : doc.documentElement.textContent;
            else
              xml.responseText = '';
              
            xml.responseXML = doc;
          }
        }
        catch(e) {
          $.event.trigger("ajaxError", [xml, s]);
		  //$.handleError(s, xml, null, e);
        }
          
        var status;
        
        status = reason != "" ? reason : "success";
        
        // Make sure that the request was successful or notmodified
        if ( status == "success" ) {
          // process the data (runs the xml through httpData regardless of callback)
          try {
            if ($.httpData) {
				//httpData doesn't exist since jQuery 1.5 - just skip it
				var data = $.httpData( xml, s.dataType, s.dataFilter);
			} else {
				var data = xml.responseText;
			}
          }
          catch (ex) {
            status = "parseerror";
          }
        }
        
        if ( status == "success" ) {
          // If a local callback was specified, fire it and pass it the data
          if ( s.success )
            s.success( data, status );
  
          // Fire the global callback
          if( s.global )
            $.event.trigger( "ajaxSuccess", [xml, s] );
        } 
        else {
            $.event.trigger("ajaxError", [xml, s]);
			//$.handleError(s, xml, status);
		}

        // Process result
        if ( s.complete )
            s.complete(xml, status);

        xml.abort();
      };
    
    // Timeout checker
    if ( s.timeout > 0 ) {
      xml.timeoutTimer = setTimeout(function(){
        // Check to see if the request is still happening
        if( !xml.requestDone ) uploadCallback( "timeout" );
      }, s.timeout);
    }
    
    $(io).load(function() { uploadCallback(""); });
    
	var oldOnSubmit = form.onsubmit;
    try {
      form.onsubmit = null;
	  form.submit();
	  form.onsubmit = oldOnSubmit;
    } 
    catch(e) {
		form.onsubmit = oldOnSubmit;
		$.event.trigger("ajaxError", [xml, s]);
		//$.handleError(s, this, null, e);
    }
    
    return xml;
 }
})(jQuery);