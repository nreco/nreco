<%@ Control Language="c#" AutoEventWireup="false" CodeFile="VfsSelector.ascx.cs" Inherits="VfsSelector"  TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<div id="vfsInsertImage<%=ClientID %>">
	<div id="vfsInsertImageFileTree<%=ClientID %>">
	</div>
	<div class="toolboxContainer">
		<button class="ui-state-default ui-corner-all" type="button" onclick="VfsSelector<%=ClientID %>.refresh()"><%=WebManager.GetLabel("Refresh",this) %></button>
	</div>	
</div>
<script language="javascript">
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
				VfsSelector<%=ClientID %>.callBack( '<%=VirtualPathUtility.AppendTrailingSlash(WebManager.BasePath) %>FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>&file='+ escape(file), file );
				$('#vfsInsertImage<%=ClientID %>').dialog('close');
			}
		);
	
	}
};
jQuery(function(){
	window.<%=OpenJsFunction %> = function(callBack) {
		if (!VfsSelector<%=ClientID %>.loaded) 
			VfsSelector<%=ClientID %>.refresh();
		VfsSelector<%=ClientID %>.callBack = callBack;
		var dlg = $('#vfsInsertImage<%=ClientID %>');
		dlg.dialog('open');
	};

	$('#vfsInsertImage<%=ClientID %>').dialog(
		{
			autoOpen : false,
			resizable : false,
			width: 330,
			height: 'auto',
			title : '<%=WebManager.GetLabel("Select Image",this).Replace("'", "\\'") %>'
		}
	);		
});
</script>
