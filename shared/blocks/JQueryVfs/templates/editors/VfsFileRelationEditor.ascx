<%@ Control Language="c#" AutoEventWireup="false" CodeFile="VfsFileRelationEditor.ascx.cs" Inherits="VfsFileRelationEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<link rel="stylesheet" type="text/css" href="css/jqueryFileUpload/jquery.fileupload-ui.css " />

<span id="<%=ClientID %>">
	<input type="hidden" runat="server" id="selectedValues" value='<%# GetSelectedItemsJson() %>'/>
	<div id="<%=ClientID %>List"></div>
	<div id="<%=ClientID %>toolBox" class="toolboxContainer">
		<% if (ShowSelect) { %>
		<span>
			<span class="ui-icon ui-icon-search"> </span>
			<a href="javascript:void(0)" onclick="relEditor<%=ClientID %>selectFile()"><%=WebManager.GetLabel("Select",this) %></a>
		</span>
		<% } %>
		<span>
			<span class="ui-icon ui-icon-plusthick"> </span>
			<a href="javascript:void(0)" onclick="relEditor<%=ClientID %>uploadFile()"><%=WebManager.GetLabel("Upload",this) %></a>
		</span>
	</div>
</span>

<script id="template-upload" type="text/x-jquery-tmpl">
    <tr class="template-upload{{if error}} ui-state-error{{/if}}">
        <td class="preview"></td>
        <td class="name" width="250">
			<div style="margin-bottom:3px;">${name}</div>
			<div class="progress"><div></div></div>
		</td>
        <td class="size">${sizef}</td>
        {{if error}}
            <td class="error" colspan="2"><%=this.GetLabel("Error") %>:
                {{if error === 'maxFileSize'}}<%=this.GetLabel("File is too big") %>
                {{else error === 'minFileSize'}}<%=this.GetLabel("File is too small") %>
                {{else error === 'acceptFileTypes'}}<%=this.GetLabel("Filetype not allowed") %>
                {{else error === 'maxNumberOfFiles'}}<%=this.GetLabel("Max number of files exceeded") %>
                {{else}}${error}
                {{/if}}
            </td>
        {{else}}
            <td class="start"><button style="display:none;"><%=this.GetLabel("Start") %></button></td>
        {{/if}}
        <td class="cancel"><button><%=this.GetLabel("Cancel") %></button></td>
    </tr>
</script>
<script id="template-download" type="text/x-jquery-tmpl">
    <tr class="template-download{{if error}} ui-state-error{{/if}}">
        {{if error}}
            <td></td>
            <td class="name" width="250">${name}</td>
            <td class="size">${sizef}</td>
            <td class="error" colspan="2"><%=this.GetLabel("Error") %>:
                {{if error === 'maxFileSize'}}<%=this.GetLabel("File is too big") %>
                {{else error === 'minFileSize'}}<%=this.GetLabel("File is too small") %>
                {{else error === 'acceptFileTypes'}}<%=this.GetLabel("Filetype not allowed") %>
                {{else error === 'maxNumberOfFiles'}}<%=this.GetLabel("Max number of files exceeded") %>
                {{else error === 'uploadedBytes'}}<%=this.GetLabel("Uploaded bytes exceed file size") %>
                {{else error === 'emptyResult'}}<%=this.GetLabel("Empty file upload result") %>
                {{else}}${error}
                {{/if}}
            </td>
        {{else}}
            <td class="preview">
                {{if thumbnail_url}}
                    <a href="${url}" target="_blank"><img src="${thumbnail_url}"></a>
                {{/if}}
            </td>
            <td class="name" width="250">
                <a href="${url}" target="_blank">${name}</a>
            </td>
            <td class="size">${sizef}</td>
            <td colspan="2"></td>
        {{/if}}
    </tr>
</script>


<%@ Register TagPrefix="Plugin" tagName="VfsSelector" src="~/templates/renderers/VfsSelector.ascx" %>
<Plugin:VfsSelector runat="server"
	AllowedExtensions='<%# AllowedExtensions %>'
	OpenJsFunction='<%# String.Format("relEditor{0}openSelectFileDialog",ClientID) %>'
	FileSystemName="<%# FileSystemName %>"/> 

<div id="fileUpload<%=ClientID %>" style="display:none">
	
	<div id="fileUploadContainer<%=ClientID %>">
		<div class="fileupload-buttonbar">
			<label class="fileinput-button" style="margin:0px">
				<span><%=this.GetLabel("Add files...") %></span>
				<input type="file" name="files[]" multiple>
			</label>
			<button type="submit" class="start"><%=this.GetLabel("Start upload") %></button>
			<button type="reset" class="cancel"><%=this.GetLabel("Cancel upload") %></button>
		</div>
		<div class="fileupload-content">
			<p class="usertip"><%=WebManager.GetLabel("Tip: you may select many files at once by pressing SHIFT or CTRL + mouse click/arrows",this) %></p>
			<div style="max-height:300px;overflow:auto;">
			<table class="files"></table>
			</div>
		</div>
	</div>
	
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
	
	var uploadPH = uplDialog.find('#fileUploadContainer<%=ClientID %>');
	
	uploadPH.unbind('fileuploadstop');
	uploadPH.unbind('fileuploaddone');
	uploadPH.unbind('fileuploadadd');
	uploadPH.bind('fileuploadstop', function (e, data) {
		uplDialog.dialog('close');
	});
	uploadPH.bind('fileuploaddone', function (e, data) {
		if (data.result!=null)
			$.each(data.result, function() {
				relEditor<%=ClientID %>addFile(this.filepath);
			});
	});
	uploadPH.bind('fileuploadadd', function (e, data) {
		if (data!=null && data.filepath!=null && data.filepath!='')
			relEditor<%=ClientID %>addFile(data.filepath);
	});
	
	uploadPH.find('.files tr').remove();
	uploadPH.fileupload('option', 'url', 
		<%=JsHelper.ToJsonString(String.Format("{0}FileTreeAjaxHandler.axd?action=upload&filesystem={1}&overwrite=false&resultFormat=json&dir={2}",WebManager.BasePath,FileSystemName, HttpUtility.UrlEncode(BasePath) ) ) %> );
	
	<% if (AllowedExtensions != null && AllowedExtensions.Length > 0) { %>
	uploadPH.fileupload('option', 'acceptFileTypes', 
		/(<%=String.Join("|", AllowedExtensions.Cast<string>().Select(e => e.Replace(".","[.]") ).ToArray())%>)$/i );
	<% } %>		

	uplDialog.dialog('open');

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
	for (var elemIdx=0; elemIdx<selectedList.length; elemIdx++) {
		var fileTitle = formatTitle(selectedList[elemIdx]);
		var fileUrl = "<%=WebManager.BasePath %>FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>&file="+encodeURI(selectedList[elemIdx]);
		var removeLinkSeparator = "&nbsp;";
		var containerStyle = "text-align:center;";
		<% if (ThumbImage) { %>
		fileTitle = "<img src='"+fileUrl+"' border='1' width='<%=ThumbImageWidth %>' alt='"+fileTitle+"'/>";
		removeLinkSeparator = "<br/>";
		containerStyle = containerStyle+"float:left;margin:5px;";
		<% } %>
		cont.append('<div class="selectedElement" style="'+containerStyle+'"><a target="_blank" href="'+fileUrl+'">'+fileTitle+'</a>'+removeLinkSeparator+'<a class="remove" href="javascript:void(0)" title="<%=this.GetLabel("Remove") %>" onclick="relEditor<%=ClientID %>Remove(\''+formatId(selectedList[elemIdx])+'\')">[x]</a></div>');
	}
	cont.append('<div class="clear"></div>');
};

jQuery(function(){
	$('#fileUpload<%=ClientID %>').dialog(
		{
			autoOpen : false,
			resizable : false,
			width: 600,
			height: 450,
			title : '<%=WebManager.GetLabel("Upload Files",this).Replace("'","\\'") %>'
		}
	);
	$('#fileUploadContainer<%=ClientID %>').fileupload({
		dataType: 'json',
		url: '',
		sequentialUploads : true,
		maxFileSize : <%=GetMaxRequestBytesLength() %>
	});	

	relEditor<%=ClientID %>RenderList();
});
</script>
	