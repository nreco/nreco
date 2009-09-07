<%@ Control Language="c#" AutoEventWireup="false" CodeFile="VfsFileRelationEditor.ascx.cs" Inherits="VfsFileRelationEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<link rel="stylesheet" type="text/css" href="css/jqueryUploadify/uploadify.css" />

<span id="<%=ClientID %>">
	<input type="hidden" runat="server" id="selectedValues" value='<%# GetSelectedItemsJson() %>'/>
	<div id="<%=ClientID %>List"></div>
	<div id="<%=ClientID %>toolBox" class="toolboxContainer">
		<span>
			<span class="ui-icon ui-icon-search"> </span>
			<a href="javascript:void(0)" onclick="relEditor<%=ClientID %>selectFile()"><%=WebManager.GetLabel("Select",this) %></a>
		</span>
		<span>
			<span class="ui-icon ui-icon-plusthick"> </span>
			<a href="javascript:void(0)" onclick="relEditor<%=ClientID %>uploadFile()"><%=WebManager.GetLabel("Upload",this) %></a>
		</span>
	</div>
</span>

<%@ Register TagPrefix="Plugin" tagName="VfsSelector" src="~/templates/renderers/VfsSelector.ascx" %>
<Plugin:VfsSelector runat="server"
	OpenJsFunction='<%# String.Format("relEditor{0}openSelectFileDialog",ClientID) %>'
	FileSystemName="<%# FileSystemName %>"/> 

<div id="fileUpload<%=ClientID %>" style="display:none">
	<p class="usertip"><%=WebManager.GetLabel("Tip: you may select many files at once by pressing SHIFT or CTRL + mouse click or arrows",this) %></p>
	<center>
		<p class="uploadArea">
			<input type="file" name="uploadify" id="uploadify<%=ClientID %>"/>
		</p>
		<p id="fileUploadQueue<%=ClientID %>"></p>
	</center>
</div>
	
<script language="javascript">
window.relEditor<%=ClientID %>Remove = function(elemId) {
	var selectedListElem = jQuery('#<%=selectedValues.ClientID %>');
	var selectedList = eval( selectedListElem.val() );
	var newSelectedList = [];
	for (var idx=0; idx<selectedList.length; idx++)
		if (selectedList[idx]!=elemId)
			newSelectedList.push(selectedList[idx]);
	selectedListElem.val( JSON.stringify(newSelectedList) );
	relEditor<%=ClientID %>RenderList();
};
window.relEditor<%=ClientID %>selectFile = function() {
	relEditor<%=ClientID %>openSelectFileDialog( function(fileUrl, fileName) {
		relEditor<%=ClientID %>addFile(fileName);
	});
};
window.relEditor<%=ClientID %>addFile = function(fileName) {
	var selectedListElem = jQuery('#<%=selectedValues.ClientID %>');
	var selectedList = eval( selectedListElem.val() );
	if ($.inArray(fileName,selectedList)>=0)
		return;
	selectedList.push( fileName );
	selectedListElem.val( JSON.stringify(selectedList) );
	relEditor<%=ClientID %>RenderList();	
};
window.relEditor<%=ClientID %>uploadFile = function() {
	var uplDialog = $('#fileUpload<%=ClientID %>');
	// remove old swf object
	uplDialog.find('.uploadArea object').remove();
	uplDialog.dialog('open');
	
	var uploadElem = uplDialog.find('#uploadify<%=ClientID %>');
	uploadElem.unbind(); // ensure that prev uploadify is not binded
	
	var scriptData = {
		'dir' : '<%=BasePath.Replace("'","\\'") %>',
		'filesystem' : '<%=FileSystemName %>', 
		'overwrite' : 'false',
		'action':'upload', 
		'authticket':'<%=Request.Cookies[System.Web.Security.FormsAuthentication.FormsCookieName]!=null ? Request.Cookies[System.Web.Security.FormsAuthentication.FormsCookieName].Value : "" %>' 
	};	
	uploadElem.uploadify({
		'uploader': '<%= VirtualPathUtility.AppendTrailingSlash(WebManager.BasePath) %>flash/uploadify.swf',
		'cancelImg': 'images/del-ico.gif',
		'script': '<%= VirtualPathUtility.AppendTrailingSlash(WebManager.BasePath) %>FileTreeAjaxHandler.axd',
		'pagePath': '<%=WebManager.BasePath %>/',
		'multi': true, 'width' : 144, 'height' : 21,
		'auto' : true,
		'queueID' : 'fileUploadQueue<%=ClientID %>',
		'simUploadLimit': 1,
		'sizeLimit' : 8388608,
		'scriptAccess' : 'always',
		'scriptData' : scriptData,
		'buttonImg' : '<%=WebManager.GetLabel("images/vfs_browse.gif",this) %>',
		'onSelect' : function(event, queueID, fileObj) {
			return true;
		},
		'onComplete': function(event,queueID,fileObj,response,data) {
			if (response!=null && response.trim().length>0)
				relEditor<%=ClientID %>addFile(response.trim());
		},
		'onAllComplete' : function(event, queueID, fileObj, response, data) {
			$('#fileUpload<%=ClientID %>').dialog('close');
		}
	});	
	
};
window.relEditor<%=ClientID %>RenderList = function() {
	var cont = jQuery('#<%=ClientID %>List');
	cont.html('');
	var selectedList = eval( jQuery('#<%=selectedValues.ClientID %>').val() );
	var formatTitle = function(s) {
		if (s.lastIndexOf("/")>=0) {
			return s.substring(s.lastIndexOf("/")+1);
		} else if (s.lastIndexOf("\\")>=0) {
			return s.substring(s.lastIndexOf("\\")+1);
		}
		return s;
	};
	var formatId = function(s) { return s.replace(/\\/g,'\\\\').replace(/'/g,"\\'"); };
	for (var elemIdx=0; elemIdx<selectedList.length; elemIdx++)
		cont.append('<div class="selectedElement">'+formatTitle(selectedList[elemIdx])+'&nbsp;<a class="remove" href="javascript:void(0)" onclick="relEditor<%=ClientID %>Remove(\''+formatId(selectedList[elemIdx])+'\')">[x]</a></div>');
};

jQuery(function(){
	$('#fileUpload<%=ClientID %>').dialog(
		{
			autoOpen : false,
			resizable : false,
			width: 400,
			height: 'auto',
			title : '<%=WebManager.GetLabel("Upload Files",this).Replace("'","\\'") %>'
		}
	);

	relEditor<%=ClientID %>RenderList();
});
</script>
	