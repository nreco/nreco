<%@ Control Language="c#" AutoEventWireup="false" CodeFile="VfsSelector.ascx.cs" Inherits="VfsSelector"  TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<div id="vfsInsertImage<%=ClientID %>">
	<div id="vfsInsertImageFileTree<%=ClientID %>">
	</div>
</div>
<script language="javascript">
jQuery(function(){
	window.<%=OpenJsFunction %> = function(callBack) {
		var dlg = $('#vfsInsertImage<%=ClientID %>');
		$('#vfsInsertImageFileTree<%=ClientID %>').fileTree( {
			multiFolder : false,
			expandSpeed : -1,
			collapseSpeed : -1,
			script : 'FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>' },
			function(file) {
				callBack( '<%=VirtualPathUtility.AppendTrailingSlash(WebManager.BasePath) %>FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>&file='+ escape(file) );
				dlg.dialog('close');
			}
		);
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
