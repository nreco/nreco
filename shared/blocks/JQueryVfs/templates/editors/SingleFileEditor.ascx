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
		var uploadUrl = "<%=WebManager.BasePath %>FileTreeAjaxHandler.axd";
		
		var uploadData = {
			action : 'upload',
			filesystem : '<%=FileSystemName %>',
			dir : <%=JsHelper.ToJsonString(BasePath) %>,
			errorprefix : 'error:',
			overwrite : <%=JsHelper.ToJsonString(AllowOverwrite) %>
		};
		<% if (AllowedExtensions != null && AllowedExtensions.Length > 0) { %>
		uploadData['allowedextensions'] = <%=JsHelper.ToJsonString( JsHelper.ToJsonString(AllowedExtensions) ) %>";
		<% } %>
		<% if (ImageFormat!=null) { %>
		uploadData['imageformat'] = "<%=ImageFormat %>";
		<% } %>
		<% if (EnsureCompressedImage) { %>
		uploadData['image'] = "compressed";
		<% } %>
		<% if (ImageMaxHeight>0) { %>
		uploadData['image_max_height']="<%=ImageMaxHeight %>";
		<% } %>
		<% if (ImageMaxWidth>0) { %>
		uploadData["image_max_width"]="<%=ImageMaxWidth %>";
		<% } %>
		
		var uploadFormData = [];
		for (var n in uploadData) {
			uploadFormData.push({
				name : n,
				value : uploadData[n]
			});
		}
		
		$.ajax( uploadUrl, {
			type : 'POST',
			formData : uploadFormData,
			iframe : true,
			dataType : 'iframe text',
			fileInput : $('#upload<%=ClientID %>')
		}).success(function(data) {
			jQuery('#<%=filePath.ClientID %>').val( data );
			doRenderCurrentFile<%=ClientID %>( data );
			
			$('#upload<%=ClientID %>').val('');
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
