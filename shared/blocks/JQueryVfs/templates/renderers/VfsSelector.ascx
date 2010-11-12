<%@ Control Language="c#" AutoEventWireup="false" CodeFile="VfsSelector.ascx.cs" Inherits="VfsSelector"  TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<div id="vfsInsertImage<%=ClientID %>">
	
	<div id="vfsInsertImageFileTree<%=ClientID %>">
	</div>
	<div class="toolboxContainer">
		<button class="ui-state-default ui-corner-all" type="button" onclick="VfsSelector<%=ClientID %>.refresh()"><%=WebManager.GetLabel("Refresh",this) %></button>
		
		<input id="upload<%=ClientID %>" name="upload<%=ClientID %>" type="file" size="15" onchange="this.value && VfsSelectorDoAjaxUpload<%=ClientID %>()"/>
	</div>	
	
</div>
<script language="javascript">
jQuery(function(){

	// remove duplicates (after async-postback)
	// dialog should be singleton
	$('.<%=ClientID %>').remove();
	var dlgContent = $('#vfsInsertImage<%=ClientID %>');
	// create new dialog container
	dlgContent.wrap('<div class="<%=ClientID %>"></div>');
	var dlg = $('.<%=ClientID %>');
	dlg.dialog(
		{
			autoOpen : false,
			resizable : false,
			width: 330,
			height: 'auto',
			title : '<%=WebManager.GetLabel("Select Image",this).Replace("'", "\\'") %>'
		}
	);

	window.VfsSelector<%=ClientID %> = {
		callBack : null,
		loaded : false,
		refresh : function() {
			this.loaded = true;
			$('#vfsInsertImageFileTree<%=ClientID %>').fileTree( {
				multiFolder : false,
				expandSpeed : -1,
				collapseSpeed : -1,
				script : '<%=VirtualPathUtility.AppendTrailingSlash(WebManager.BasePath) %>FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>' },
				function(file) {
					VfsSelector<%=ClientID %>.callBack( '<%=VirtualPathUtility.AppendTrailingSlash(WebManager.BasePath) %><%=VfsHelper.GetFileUrl(FileSystemName,"") %>'+ encodeURI(file), file );
					dlg.dialog('close');
				}
			);
		
		}
	};
	window.<%=OpenJsFunction %> = function(callBack) {
		if (!VfsSelector<%=ClientID %>.loaded) 
			VfsSelector<%=ClientID %>.refresh();
		VfsSelector<%=ClientID %>.callBack = callBack;
		dlg.dialog('open');
	};	

	window.VfsSelectorDoAjaxUpload<%=ClientID %> = function() {
		var uploadUrl = "FileTreeAjaxHandler.axd?action=upload&filesystem=<%=FileSystemName %>&dir=<%=HttpUtility.UrlEncode(UploadFolderPath) %>&overwrite=false";
		$('#upload<%=ClientID %>').ajaxFileUpload({
			url: uploadUrl,
			data: {'UPLOAD_IDENTIFIER': '<%=ClientID %>'},
			dataType: 'text',
			timeout: 60000, // 1 min
			success: function(data, status) {
				if (status=="success") {
					VfsSelector<%=ClientID %>.callBack('<%=VirtualPathUtility.AppendTrailingSlash(WebManager.BasePath) %><%=VfsHelper.GetFileUrl(FileSystemName,"") %>'+ encodeURI(data), data );
					dlg.dialog('close');					
				} else {
					alert('<%=WebManager.GetLabel("Upload error",this) %>');
				}
				$('#upload<%=ClientID %>').val('');
			},
			error: function(data, status, e) {}
		});		
	
	};
	
	
});
</script>
