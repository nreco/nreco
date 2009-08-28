<%@ Control Language="c#" AutoEventWireup="false" CodeFile="SingleFileEditor.ascx.cs" Inherits="SingleFileEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<span id="<%=ClientID %>">
	<input type="hidden" id="filePath" runat="server" value="<%# Value %>"/>
	<div class="SingleFileEditor filename" id="uploadFileMessage<%=ClientID %>"></div>
	<% if (!ReadOnly) { %>
	<div class="SingleFileEditor upload" id="uploadFileContainer<%=ClientID %>">
		<input id="upload<%=ClientID %>" name="upload<%=ClientID %>" type="file" size="35" onchange="this.value && doIframeUpload<%=ClientID %>()"/>
	</div>
	<% } %>
	
	<script type="text/javascript">
	<% if (!ReadOnly) { %>
	window.doIframeUpload<%=ClientID %> = function() {
		jQuery('#uploadFileContainer<%=ClientID %>').hide();
		jQuery('#uploadFileMessage<%=ClientID %>').html('Uploading...');
		
		var uploadUrl = "FileTreeAjaxHandler.axd?action=upload&filesystem=<%=FileSystemName %>&dir=<%=HttpUtility.UrlEncode(BasePath) %>&overwrite=<%=AllowOverwrite.ToString().ToLower() %>&jscallback=iframeUploadCallback<%=ClientID %>";
		var form = $("#<%=ClientID %>").parents("form:first")[0];
		var ifname = 'upload_i_<%=ClientID %>' + new Date().getTime();
		var s = jQuery('<div style="position:absolute;display:none;visibility:hidden;" class="iframeUpload<%=ClientID %>"><iframe name="' + ifname + '" id="' + ifname + '" style="width:0px; height:0px; overflow:hidden; border:none" ></iframe></div>');
		
		s.appendTo('body');
		
		var setAttributes = function(e, attr) {
			var sv = {}, form = e;
			if (e.mergeAttributes) {
				form = document.createElement('form');
				form.mergeAttributes(e, false);
			}
			for (var k in attr) {
				sv[k] = form.getAttribute(k);
				form.setAttribute(k, attr[k]);
			}
			if (e.mergeAttributes)
				e.mergeAttributes(form, false);
			return sv;
		};
		setTimeout(function() {
			var savedNames = [];
			for (var i = 0, n = form.elements.length; i < n; i++) {
				savedNames[i] = form.elements[i].name;
				form.elements[i].name = '';
			}
			document.getElementById('upload<%=ClientID %>').name = 'Filedata';
			var sv = setAttributes(form, { action: uploadUrl, method: 'POST', enctype : 'multipart/form-data', encoding : 'multipart/form-data', onsubmit: null, target: ifname });
			form.submit();
			setAttributes(form, sv);
			for (i = 0, n = form.elements.length; i < n; i++)
				form.elements[i].name = savedNames[i];
		}, 100);
	};
	window.iframeUploadCallback<%=ClientID %> = function(filePath) {
		jQuery('#<%=filePath.ClientID %>').val( filePath );
		doRenderCurrentFile<%=ClientID %>( filePath );
		
		jQuery('.iframeUpload<%=ClientID %>').remove();
		
		// flush upload textbox
		var uploadContainer = jQuery('#uploadFileContainer<%=ClientID %>');
		uploadContainer.html( uploadContainer.html() ).show();
		
	};
	window.doClearCurrentFile<%=ClientID %> = function() {
		jQuery('#<%=filePath.ClientID %>').val('');
		doRenderCurrentFile<%=ClientID %>('');
	};
	<% } %>
	window.doRenderCurrentFile<%=ClientID %> = function(filePath) {
		var fileHtml = '';
		var fileExt = filePath.lastIndexOf('.')>=0 ? filePath.substring( filePath.lastIndexOf('.')+1 ).toLowerCase() : "";
		if (filePath.length>0) {
			var fileName = filePath.lastIndexOf('/')>=0 ? filePath.substring( filePath.lastIndexOf('/')+1 ) : filePath;
			fileHtml = '<a class="filename" href="FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>&file='+escape(filePath)+'">'+fileName+'</a>';
			<% if (!ReadOnly) { %>
			fileHtml += '&nbsp;<a href="javascript:void(0)" onclick="doClearCurrentFile<%=ClientID %>()">[x]</a>';
			<% } %>
			fileHtml += '<div class="preview" style="position:absolute;display:none;"><div class="message">Loading...</div><img style="display:none" border="0"/></div>';
		}
		jQuery('#uploadFileMessage<%=ClientID %>').html(fileHtml);
		if (filePath.length>0 && (fileExt=='jpg' || fileExt=='gif' || fileExt=='png' || fileExt=='jpeg') ) {
			jQuery('#uploadFileMessage<%=ClientID %> .filename').mouseover( function() {
				jQuery('#uploadFileMessage<%=ClientID %> .preview').show();
				var img = jQuery('#uploadFileMessage<%=ClientID %> .preview img');
				img.load( function() {
					var imgHeight = this.height;
					var imgWidth = this.width;
					var imgElem = this;
					if (imgHeight==0 && imgWidth==0) {
						// hack for IE
						var nImg = new Image()
						nImg.src = this.src;
						imgHeight = nImg.height;
						imgWidth = nImg.width;
					}					
					if (imgWidth>150 || imgHeight>150) {
						var scale = Math.min( 200/imgWidth, 200/imgHeight );
						jQuery(imgElem).height( imgHeight * scale );
						jQuery(imgElem).width( imgWidth * scale );						
					}
					jQuery(imgElem).show();
					jQuery('#uploadFileMessage<%=ClientID %> .preview .message').hide();
				} ).attr('src', 'FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>&file='+escape(filePath) );
			}).mouseout( function() {
				jQuery('#uploadFileMessage<%=ClientID %> .preview').hide();
			});
		}
	};
	doRenderCurrentFile<%=ClientID %>( jQuery('#<%=filePath.ClientID %>').val() );
	</script>
</span>
