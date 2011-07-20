<%@ Control Language="c#" AutoEventWireup="false" CodeFile="SingleFileEditor.ascx.cs" Inherits="SingleFileEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<span id="<%=ClientID %>">
	<input type="hidden" id="filePath" runat="server" value="<%# Value %>"/>
	<div class="SingleFileEditor filename" id="uploadFileMessage<%=ClientID %>"></div>
	<% if (!ReadOnly) { %>
	<div class="SingleFileEditor upload" id="uploadFileContainer<%=ClientID %>">
		<input id="upload<%=ClientID %>" name="upload<%=ClientID %>" type="file" size="35" onchange="this.value && doAjaxUpload<%=ClientID %>()"/>
	</div>
	<% } %>
	
	<script type="text/javascript">
	<% if (!ReadOnly) { %>
	window.doAjaxUpload<%=ClientID %> = function() {
		var uploadUrl = "FileTreeAjaxHandler.axd?action=upload&filesystem=<%=FileSystemName %>&dir=<%=HttpUtility.UrlEncode(BasePath) %>&errorprefix=<%=HttpUtility.UrlEncode("error:") %>&overwrite=<%=AllowOverwrite.ToString().ToLower() %><%= AllowedExtensions != null && AllowedExtensions.Length > 0 ? ("&allowedextensions=" + HttpUtility.UrlEncode(JsHelper.ToJsonString(AllowedExtensions))) : ""%>";
		<% if (ImageFormat!=null) { %>
		uploadUrl = uploadUrl + "&imageformat=<%=ImageFormat %>";
		<% } %>
		<% if (EnsureCompressedImage) { %>
		uploadUrl = uploadUrl+"&image=compressed";
		<% } %>
		<% if (ImageMaxHeight>0) { %>
		uploadUrl = uploadUrl+"&image_max_height=<%=ImageMaxHeight %>";
		<% } %>
		<% if (ImageMaxWidth>0) { %>
		uploadUrl = uploadUrl+"&image_max_width=<%=ImageMaxWidth %>";
		<% } %>
		
		$('#upload<%=ClientID %>').ajaxFileUpload({
			url: uploadUrl,
			data: {'UPLOAD_IDENTIFIER': '<%=ClientID %>'},
			dataType: 'text',
			timeout: 60000, // 1 min
			success: function(data, status) {
				if (status=="success") {
					if (data.indexOf('error:')==0) {
						$(window).trigger( "ajaxError", [{statusText:data.substr(6),status:500}, this] );
					} else {
						jQuery('#<%=filePath.ClientID %>').val( data );
						doRenderCurrentFile<%=ClientID %>( data );
					}
				} else {
					$(window).trigger( "ajaxError", [{statusText:'<%=WebManager.GetLabel("Upload error",this) %>',status:500}, this] );
				}
				$('#upload<%=ClientID %>').val('');
			},
			error: function(data, status, e) {
				//
			}
		});		
	
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
			var lastPathSeparator = Math.max( filePath.lastIndexOf('/'), filePath.lastIndexOf('\\') );
			var fileName = lastPathSeparator>=0 ? filePath.substring( lastPathSeparator+1 ) : filePath;
			fileHtml = '<a class="filename" target="_blank" href="FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>&file='+encodeURI(filePath)+'">'+fileName+'</a>';
			<% if (!ReadOnly) { %>
			fileHtml += '&nbsp;<a href="javascript:void(0)" onclick="doClearCurrentFile<%=ClientID %>()">[x]</a>';
			<% } %>
			fileHtml += '<div class="preview" style="position:absolute;display:none;"><div class="message">Loading...</div><img style="display:none" border="0"/></div>';
		}
		jQuery('#uploadFileMessage<%=ClientID %>').html(fileHtml);
		if (filePath.length>0 && (fileExt=='jpg' || fileExt=='gif' || fileExt=='png' || fileExt=='jpeg' || fileExt=='ico') ) {
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
				} ).attr('src', 'FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>&file='+encodeURI(filePath) );
			}).mouseout( function() {
				jQuery('#uploadFileMessage<%=ClientID %> .preview').hide();
			});
		}
	};
	doRenderCurrentFile<%=ClientID %>( jQuery('#<%=filePath.ClientID %>').val() );
	</script>
</span>
