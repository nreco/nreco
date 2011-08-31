<%@ Control Language="c#" AutoEventWireup="false" CodeFile="VfsManager.ascx.cs" Inherits="VfsManager"  TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<link rel="stylesheet" type="text/css" href="css/jqueryFileTree/jqueryFileTree.css" />
<link rel="stylesheet" type="text/css" href="css/jqueryFileUpload/jquery.fileupload-ui.css " />

<div id="fileTree<%=ClientID %>">
	<ul class="jqueryFileTree">
		<li class="directory collapsed"><a class='directory' href="#" rel="<%= RootPath %>" filename=""><span class="name"><%=WebManager.GetLabel("Root",this) %></span></a></li>
	</ul>
</div>
<div id="fileImagePreview<%=ClientID %>" title="<%=WebManager.GetLabel("Image Preview",this) %>" style="display:none">
</div>
<div id="fileRename<%=ClientID %>" style="display:none">
	<input class="fileRename" type="text"/>
</div>
<div id="dirCreate<%=ClientID %>" style="display:none">
	<input class="fileRename" type="text"/>
</div>
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
            <td class="start"><button><%=this.GetLabel("Start") %></button></td>
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


<span id="fileManagerToolBar<%=ClientID %>" class="ui-state-default fileTreeToolbar">
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>move" class="menuitem" title="<%=this.GetLabel("Move") %>">
		<span class="ui-icon ui-icon-arrow-4"></span>
		<span class="title"><%=this.GetLabel("Move") %></span>
	</a>
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>upload" class="menuitem" title="<%=this.GetLabel("Upload") %>">
		<span class="ui-icon ui-icon-arrowthickstop-1-s"></span>
		<span class="title"><%=this.GetLabel("Upload files") %></span>
	</a>
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>reload" class="menuitem" title="<%=this.GetLabel("Refresh") %>">
		<span class="ui-icon ui-icon-refresh"></span>
		<span class="title"><%=this.GetLabel("Refresh") %></span>
	</a>
	
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>createFolder" class="menuitem" title="<%=this.GetLabel("Create Folder") %>">
		<span class="ui-icon ui-icon-plus"></span>
		<span class="title"><%=this.GetLabel("Create Folder") %></span>
	</a>

	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>rename" class="menuitem" title="<%=this.GetLabel("Rename") %>">
		<span class="ui-icon ui-icon-pencil"></span>
		<span class="title"><%=this.GetLabel("Rename") %></span>
	</a>	
	
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>delete" class="menuitem" title="<%=this.GetLabel("Delete") %>">
		<span class="ui-icon ui-icon-trash"></span>
		<span class="title"><%=this.GetLabel("Delete") %></span>
	</a>
</span>

<script language="javascript">
window.FileManager<%=ClientID %> = {
	toolBarFile : null,
	ajaxHandler : '<%=VirtualPathUtility.AppendTrailingSlash(WebManager.BasePath) %>FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>&extraInfo=1',
	root: '<%= RootPath %>',
	multiFolder : true,
	loadMessage : '<%=WebManager.GetLabel("Loading...",this).Replace("'", "\\'") %>',
	errorMessage : '<%=WebManager.GetLabel("Error!",this) %>',
	treeId : 'fileTree<%=ClientID %>',
	startDirParts : <%= String.IsNullOrEmpty(StartDir) ? "null" : JsHelper.ToJsonString(StartDir.Split('/', '\\') ) %>,
	
	init : function() {
		// Get the initial file list
		this.bindTree( $('#'+this.treeId+' UL') );
		var rootElem = $('#'+this.treeId).find('UL LI');
		this.showTree( rootElem, encodeURI(this.root), this.startDirParts==null );
		
		if (this.startDirParts!=null) {
			for (var i=0; i<this.startDirParts.length; i++) {
				var pathParts = this.startDirParts.slice(0, i+1);
				var path = pathParts.join('/')+'/';
				$('#'+this.treeId+' a.directory').each(function() {
					var folderElem = $(this);
					if (folderElem.attr('rel').toLowerCase()==path.toLowerCase()) 
						FileManager<%=ClientID %>.showTree(folderElem.parents('li:first').removeClass('collapsed').addClass('expanded'), folderElem.attr('rel'), false);
				});
			};
		}
	},
	
	showTree : function(c, t, loadAsync) {
		c.addClass('wait');
		FileManager<%=ClientID %>.resetToolbar();
		$.ajax( {
			url : this.ajaxHandler,
			type: "POST",
			async: typeof(loadAsync)!='undefined' ? loadAsync : true,
			data : { dir: t }, 
			success : function(data) {
				FileManager<%=ClientID %>.resetToolbar();
				c.removeClass('wait').append(data);
				if( FileManager<%=ClientID %>.root == t ) 
					c.find('UL:hidden').show(); 
				else 
					c.find('UL:hidden').show();
				FileManager<%=ClientID %>.bindTree( c );
			}
		});
	},
				
	switchTreeAction : function(entry) {
		if( entry.parent('LI').hasClass('directory') ) {
			if( entry.parent('LI').hasClass('collapsed') ) {
				// Expand
				if( !this.multiFolder ) {
					entry.parent().parent().find('UL').show();
					entry.parent().parent().find('LI.directory').removeClass('expanded').addClass('collapsed');
				}
				entry.parent().find('.ui-draggable').draggable('destroy');
				FileManager<%=ClientID %>.resetToolbar();
				entry.parent().find('UL').remove(); // cleanup
				this.showTree( entry.parent(), encodeURI(entry.attr('rel').match( /.*\// )) );
				entry.parent().removeClass('collapsed').addClass('expanded');
			} else if (entry.parent('LI').hasClass('expanded')) {
				// Collapse
				entry.parent().removeClass('expanded').addClass('collapsed');
				entry.parent().find('UL').hide();
			}
		} else {
			this.viewFile(entry.attr('rel'), entry);
		}
	},
	
	bindTree : function(elem) {
		elem.find('LI A').unbind('click').click( function() {
			FileManager<%=ClientID %>.switchTreeAction($(this));
			return false;
		});
		elem.find('LI a').unbind('hover').hover( this.mouseover, this.mouseout );
		
		elem.find('LI A.file').draggable( { 
			handle : '#fileManagerToolBar<%=ClientID %>move',
			revert : true
		} );
		var ajaxHandler = this.ajaxHandler;
		var errorMsg = this.errorMessage;
		elem.find('LI A.directory').droppable( {
			tolerance : 'pointer',
			accept : '.file',
			activeClass: '.dropSelected',
			hoverClass: '.dropSelected',
			drop: function(event, ui) {
				var destFolder = $(this);
				var destFolderPath = destFolder.attr('rel');
				var moveFile = ui.draggable;
				var moveFileName = moveFile.attr('rel');
				
				if (!confirm('<%=this.GetLabel("Move:") %> '+moveFile.attr('filename')+'\n<%=this.GetLabel("Are you sure?") %>')) {
					return false;
				}
				destFolder.parent('LI').addClass('wait');
				
				$.ajax({
					type: "GET", async: true,
					url: ajaxHandler,
					data : {'file':moveFileName,'action':'move', 'dest':destFolderPath},
					success : function(res) {
						FileManager<%=ClientID %>.resetToolbar();
						moveFile.find('.draggable').draggable('destroy');
						moveFile.parent('LI').remove();
						// mark dest folder as collapsed. This will force it to reload
						destFolder.parent('LI').removeClass('expanded').addClass('collapsed')
						FileManager<%=ClientID %>.switchTreeAction(destFolder);
					},
					error : function(err) {
						destFolder.parent('LI').removeClass('wait');
						alert(errorMsg);
					}
				});
				
				return false;
			}
		} );
	},
	
	toolBarIconIds : {
		'upload' : 'fileManagerToolBar<%=ClientID %>upload',
		'move': 'fileManagerToolBar<%=ClientID %>move',
		'rename' : 'fileManagerToolBar<%=ClientID %>rename',
		'delete' : 'fileManagerToolBar<%=ClientID %>delete',
		'createFolder' : 'fileManagerToolBar<%=ClientID %>createFolder',
		'reload' : 'fileManagerToolBar<%=ClientID %>reload'
	},
	
	setupToolbar : function(fileElem) {
		var fileName = fileElem.attr('rel');
		if (this.toolBarFile==fileName)
			return false;
		this.toolBarFile = fileName;
		var icons = (fileName!='' && fileName!='<%=RootPath %>') ? { 'rename' : true, 'delete' : true } : {};
		if (fileElem.parent('LI').hasClass('directory')) {
			icons.upload = true;
			icons.createFolder = true;
			icons.reload = true;
		} else {
			icons.move = true;
		}
		for (var iconName in this.toolBarIconIds)
			if (icons[iconName])
				$('#'+this.toolBarIconIds[iconName]).show();
			else
				$('#'+this.toolBarIconIds[iconName]).hide();
				
		return true;
	},
	
	resetToolbar : function() {
		$('#fileManagerToolBar<%=ClientID %>').hide().appendTo( '#fileTree<%=ClientID %>' )
	},
	
	reload : function(fileElem) {
		fileElem.parent('LI.directory').removeClass('expanded').addClass('collapsed');
		this.switchTreeAction(fileElem);
	},
	
	renameFile : function(fileElem) {
		var fileName = fileElem.attr('rel');
		var renDialog = $('#fileRename<%=ClientID %>');
		renDialog.find('input').val( fileElem.attr('filename') );
		var ajaxHandler = this.ajaxHandler;
		var renameHandler = function() { 
			fileElem.parent('LI').addClass('wait');
			$.ajax({
				type: "GET", async: true,
				url: ajaxHandler,
				data : {'file':fileName,'action':'rename','newname':renDialog.find('input').val() },
				success : function(res) {
					var fileEntry = fileElem.parent('LI');
					FileManager<%=ClientID %>.resetToolbar();
					var fileEntryParent = fileEntry.parent();
					fileEntry.replaceWith(res);
					FileManager<%=ClientID %>.bindTree( fileEntryParent );
				},
				error : function(err) {
					fileElem.parent('LI').removeClass('wait');
					alert('Error!');
				}
			});
			renDialog.dialog("close");
		};
		renDialog.find('input').unbind('keydown').keydown( function(e) { if (e.keyCode==13) renameHandler(); });
		renDialog.dialog('option', 'buttons', {
				"<%=WebManager.GetLabel("Rename",this).Replace("\"", "\\\"") %>": renameHandler								
			});
		renDialog.dialog('option', 'width', 330 );
		renDialog.dialog('open');
	},
	
	createFolder : function(fileElem) {
		var dirName = fileElem.attr('rel');
		var dirCreateDialog = $('#dirCreate<%=ClientID %>');
		dirCreateDialog.find('input').val('');
		var ajaxHandler = this.ajaxHandler;
		var errorMsg = this.errorMessage;
		var createHandler = function() { 
			fileElem.parent('LI').addClass('wait');
			$.ajax({
				type: "GET", async: true,
				url: ajaxHandler,
				data : {'dir':dirName,'action':'createdir','dirname':dirCreateDialog.find('input').val() },
				success : function(res) {
					fileElem.parent('LI').removeClass('expanded').addClass('collapsed');
					FileManager<%=ClientID %>.switchTreeAction(fileElem);							
				},
				error : function(err) {
					fileElem.parent('LI').removeClass('wait');
					alert(errorMsg);
				}
			});
			dirCreateDialog.dialog("close");
		};
		dirCreateDialog.find('input').unbind('keydown').keydown( function(e) { if (e.keyCode==13) createHandler(); });
		dirCreateDialog.dialog('option', 'buttons', {
				"<%=WebManager.GetLabel("Create",this).Replace("\"", "\\\"") %>":createHandler							
			});
		dirCreateDialog.dialog('open');
	},	
	
	
	uploadFile : function(fileElem) {
		var dirName = fileElem.attr('rel').replace('\\','/');
		var uplDialog = $('#fileUpload<%=ClientID %>');

		var uploadPH = uplDialog.find('#fileUploadContainer<%=ClientID %>');
		uploadPH.unbind('fileuploadstop');
		uploadPH.bind('fileuploadstop', function (e, data) {
			fileElem.parent('LI').removeClass('expanded').addClass('collapsed')
			FileManager<%=ClientID %>.switchTreeAction(fileElem);
			fileElem.parent().effect("highlight", {color:'#909090'}, 1500);
		});
		uploadPH.find('.files tr').remove();
		uploadPH.fileupload('option', 'url', 
			<%=JsHelper.ToJsonString(String.Format("{0}FileTreeAjaxHandler.axd?action=upload&filesystem={1}&overwrite=true&resultFormat=json",WebManager.BasePath,FileSystemName) ) %>+"&dir="+encodeURI(dirName) );

		if (dirName.length==0 || dirName.substring(0,1)!='/')
			dirName = '/'+dirName;
		uplDialog.dialog('option', 'title', '<%=WebManager.GetLabel("Upload Files",this).Replace("'","\\'") %>: '+dirName);
		uplDialog.dialog('open');
	},
	
	deleteFile : function(fileElem) {
		var fileName = fileElem.attr('rel')
		if (!confirm('<%=this.GetLabel("Delete:") %> '+fileElem.attr('filename')+'\n<%=WebManager.GetLabel("Are you sure?",this).Replace("'","\\'") %>')) return;
		fileElem.parent('LI').addClass('wait');
		$.ajax({
			type: "GET", async: true,
			url: this.ajaxHandler,
			data : {'file':fileName,'action':'delete'},
			success : function(res) {
				var fileEntry = fileElem.parent('LI');
				FileManager<%=ClientID %>.resetToolbar();
				fileEntry.remove();
			},
			error : function(err) {
				fileElem.parent('LI').removeClass('wait');
				alert('Error!');
			}
		});
	},
	
	mouseover : function() {
		if (FileManager<%=ClientID %>.setupToolbar( $(this) )) {
			$('#fileManagerToolBar<%=ClientID %>').appendTo( $(this) ).css('display','inline');
			$(this).css("margin-right", $('#fileManagerToolBar<%=ClientID %>').width() );
		}
	},
	mouseout : function() {
		$('#fileManagerToolBar<%=ClientID %>').hide();
		FileManager<%=ClientID %>.toolBarFile = null;
		$(this).css("margin-right", 0);
	},
	
	viewFile : function(file, elem) {
			var fileUrl = this.ajaxHandler+'&file='+encodeURI(file);
			/* images preview */
			var bgImg = elem.parent('li').css('background-image');
			var preview = jQuery('#fileImagePreview<%=ClientID %>');
			if ( bgImg.indexOf('picture.png')>=0 ) {
				var dialogDiv = preview.html("<div></div>").find('div');
				
				var maxParentHeight = $(window).height()*0.8;
				var maxParentWidth = $(window).width()*0.8;
				
				dialogDiv.html('<center><a target="_blank" href="'+fileUrl+'"><img border="0"/></a></center>');
				
				var scaleFunc = function(img, imgWidth, imgHeight) {
					if (imgHeight>0 && imgWidth>0) {
						var scaleWidth = 1;
						var scaleHeight = 1;
						if (imgWidth>maxParentWidth)
							scaleWidth = (maxParentWidth/imgWidth );
						if (imgHeight>maxParentHeight)
							scaleHeight = (maxParentHeight/imgHeight );
						var scale = scaleHeight < scaleWidth ? scaleHeight : scaleWidth;
						img.height( imgHeight * scale );
						img.width( imgWidth * scale );
						dialogDiv.dialog('option', 'width', Math.max((imgWidth * scale)+40,300) );
					}			
					dialogDiv.dialog('open');
				};
				var img = dialogDiv.find('img');
				dialogDiv.dialog(
					{
						autoOpen : false,
						maxHeight: maxParentHeight,
						maxWidth: maxParentWidth,
						minWidth : 300,
						minHeight: 100,
						width: 'auto',
						height: 'auto',
						title : elem.attr('filename'),
						buttons: { 
							"<%=WebManager.GetLabel("Open in New Window",this).Replace("\"","\\\"") %>": function() { 
								window.open( fileUrl, '_blank');
							}								
						}
					}
				);
				
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
					scaleFunc( $(imgElem), imgWidth, imgHeight);
				}).attr('src', fileUrl);
				//alert(img.attr('complete'));
				if (img.attr('complete')) {
					scaleFunc(img, img.attr('width'), img.attr('height') );
				}
				
			} else if (bgImg.indexOf('code.png')>=0 || bgImg.indexOf('txt.png')>=0 || bgImg.indexOf('script.png')>=0 ) {
				var dialogDiv = preview.html("<div></div>").find('div');
				var maxParentHeight = $(window).height()*0.6;
				var maxParentWidth = $(window).width()*0.6;				
				dialogDiv.html('<center><iframe border="0" src="'+fileUrl+'" width="'+maxParentWidth+'" height="'+maxParentHeight+'"></iframe></center>');
				dialogDiv.dialog(
					{
						autoOpen : true,
						width: maxParentWidth+40,
						height: 'auto',
						title : elem.text(),
						buttons: { 
							"Open in New Window": function() { 
								window.open( fileUrl, '_blank');
							}								
						}
					}
				);				
				
			} else {
				window.open( fileUrl, '_blank');
			}
		}

};

jQuery(function(){
	FileManager<%=ClientID %>.init();
	// handlers
	$('#fileManagerToolBar<%=ClientID %>delete').click( 
		function() { 
			FileManager<%=ClientID %>.deleteFile( $(this).parent().parent('A') );
			return false; } );
	$('#fileManagerToolBar<%=ClientID %>rename').click( 
		function() { 
			FileManager<%=ClientID %>.renameFile( $(this).parent().parent('A') );
			return false; } );
	$('#fileManagerToolBar<%=ClientID %>reload').click( 
		function() { 
			FileManager<%=ClientID %>.reload( $(this).parent().parent('A') );
			return false; } );

	$('#fileManagerToolBar<%=ClientID %>createFolder').click( 
		function() { 
			FileManager<%=ClientID %>.createFolder( $(this).parent().parent('A') );
			return false; } );
			
	$('#fileManagerToolBar<%=ClientID %>upload').click( 
		function() { 
			FileManager<%=ClientID %>.uploadFile( $(this).parent().parent('A') );
			return false; } );
	// init dialogs
	$('#fileRename<%=ClientID %>').dialog(
		{
			autoOpen : false,
			resizable : false,
			width: 'auto',
			height: 'auto',
			title : '<%=WebManager.GetLabel("Rename",this).Replace("'","\\'") %>'
		}
	);
	$('#fileUpload<%=ClientID %>').dialog(
		{
			autoOpen : false,
			resizable : false,
			width: 600,
			height: 440,
			title : '<%=WebManager.GetLabel("Upload Files",this).Replace("'","\\'") %>'
		}
	)
	$('#fileUploadContainer<%=ClientID %>').fileupload({
		dataType: 'json',
		url: '',
		sequentialUploads : true,
		maxFileSize : <%=GetMaxRequestBytesLength() %>
	});
	
	$('#dirCreate<%=ClientID %>').dialog(
		{
			autoOpen : false,
			resizable : false,
			width: 330,
			height: 'auto',
			title : '<%=WebManager.GetLabel("Create Folder",this).Replace("'","\\'") %>'
		}
	);	
	
	
});
</script>
	