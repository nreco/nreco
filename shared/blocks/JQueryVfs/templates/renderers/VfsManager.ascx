<%@ Control Language="c#" AutoEventWireup="false" CodeFile="VfsManager.ascx.cs" Inherits="VfsManager"  TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<link rel="stylesheet" type="text/css" href="css/jqueryFileTree/jqueryFileTree.css" />

<div id="fileTree<%=ClientID %>">
	<ul class="jqueryFileTree">
		<li class="directory collapsed"><a class='directory' href="#" rel="/" filename=""><%=WebManager.GetLabel("Root",this) %></a></li>
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
</div>

<span id="fileManagerToolBar<%=ClientID %>" class="fileTreeToolbar" style="display:none; position:absolute; float:left; padding-left: 5px; width: 150px;">
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>move" class="ui-state-default ui-corner-all icon" title="Move">
		<span class="ui-icon ui-icon-arrow-4"></span>
	</a>
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>upload" class="ui-state-default ui-corner-all icon" title="Upload">
		<span class="ui-icon ui-icon-arrowthickstop-1-s"></span>
	</a>
	
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>reload" class="ui-state-default ui-corner-all icon" title="Refresh">
		<span class="ui-icon ui-icon-refresh"></span>
	</a>
	
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>createFolder" class="ui-state-default ui-corner-all icon" title="Create Folder">
		<span class="ui-icon ui-icon-plus"></span>
	</a>

	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>rename" class="ui-state-default ui-corner-all icon" title="Rename">
		<span class="ui-icon ui-icon-pencil"></span>
	</a>	
	
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>delete" class="ui-state-default ui-corner-all icon" title="Delete">
		<span class="ui-icon ui-icon-trash"></span>
	</a>
</span>

<script language="javascript">
window.FileManager<%=ClientID %> = {
	toolBarFile : null,
	ajaxHandler : '<%=VirtualPathUtility.AppendTrailingSlash(WebManager.BasePath) %>FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>&extraInfo=1',
	root: '/',
	multiFolder : true,
	loadMessage : '<%=WebManager.GetLabel("Loading...",this).Replace("'", "\\'") %>',
	errorMessage : '<%=WebManager.GetLabel("Error!",this) %>',
	treeId : 'fileTree<%=ClientID %>',
	
	init : function() {
		// Get the initial file list
		this.bindTree( $('#'+this.treeId+' UL') );
		this.showTree( $('#'+this.treeId).find('UL LI'), escape(this.root) );
	},
	
	showTree : function(c, t) {
		c.addClass('wait');
		FileManager<%=ClientID %>.resetToolbar();
		$.post(this.ajaxHandler, { dir: t }, function(data) {
			FileManager<%=ClientID %>.resetToolbar();
			c.removeClass('wait').append(data);
			if( FileManager<%=ClientID %>.root == t ) 
				c.find('UL:hidden').show(); 
			else 
				c.find('UL:hidden').show();
			FileManager<%=ClientID %>.bindTree( c );
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
				this.showTree( entry.parent(), escape(entry.attr('rel').match( /.*\// )) );
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
		elem.find('LI A').unbind('mouseover').unbind('mouseout').mouseover( this.mouseover ).mouseout( this.mouseout );
		elem.find('LI A.file').draggable( { 
			handle : '#fileManagerToolBar<%=ClientID %>move',
			revert : 'invalid'
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
		var icons = (fileName!='' && fileName!='/') ? { 'rename' : true, 'delete' : true } : {};
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
		renDialog.dialog('option', 'buttons', {
				"<%=WebManager.GetLabel("Rename",this).Replace("\"", "\\\"") %>": function() { 
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
				}								
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
		dirCreateDialog.dialog('option', 'buttons', {
				"<%=WebManager.GetLabel("Create",this).Replace("\"", "\\\"") %>": function() { 
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
				}								
			});
		dirCreateDialog.dialog('open');
	},	
	
	
	uploadFile : function(fileElem) {
		var dirName = fileElem.attr('rel');
		var uplDialog = $('#fileUpload<%=ClientID %>');
		
		uplDialog.html('<center><div id="fileUploader<%=ClientID %>"></div></center>');
		$('#fileUploader<%=ClientID %>').fileUpload({
			'uploader': 'flash/uploader.swf',
			'cancelImg': 'images/del-ico.gif',
			'script': 'FileTreeAjaxHandler.axd',
			'pagePath': '<%=WebManager.BasePath %>/',
			'multi': true, 'width' : 144, 'height' : 21,
			'auto' : true,
			'scriptData' : {
				'dir' : dirName,
				'filesystem' : '<%=FileSystemName %>', 
				'action':'upload', 
				'authticket':'<%=Request.Cookies[System.Web.Security.FormsAuthentication.FormsCookieName]!=null ? Request.Cookies[System.Web.Security.FormsAuthentication.FormsCookieName].Value : "" %>' },
			'simUploadLimit': 1,
			'sizeLimit' : 8388608,
			'scriptAccess' : 'always',
			'buttonImg' : 'images/vfs_browse.gif',
			'onSelect' : function(event, queueID, fileObj) {
				return true;
			},
			'onAllComplete' : function(event, queueID, fileObj, response, data) {
				fileElem.parent('LI').removeClass('expanded').addClass('collapsed')
				FileManager<%=ClientID %>.switchTreeAction(fileElem);
				$('#fileUpload<%=ClientID %>').dialog('close');
			}
		});	
		uplDialog.dialog('option', 'width', 330 );
		uplDialog.dialog('open');
	},
	
	deleteFile : function(fileElem) {
		var fileName = fileElem.attr('rel')
		if (!confirm('<%=WebManager.GetLabel("Are you sure?",this).Replace("'","\\'") %>')) return;
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
			var fileUrl = this.ajaxHandler+'&file='+escape(file);
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
						dialogDiv.dialog('option', 'width', Math.max((imgWidth * scale)+40,150) );
					}			
					dialogDiv.dialog('open');
				};
				var img = dialogDiv.find('img');
				dialogDiv.dialog(
					{
						autoOpen : false,
						maxHeight: maxParentHeight,
						maxWidth: maxParentWidth,
						minWidth : 150,
						minHeight: 100,
						width: 'auto',
						height: 'auto',
						title : elem.text(),
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
				
			} else if (bgImg.indexOf('code.png')>=0 || bgImg.indexOf('txt.png') || bgImg.indexOf('script.png')) {
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
			width: 'auto',
			height: 'auto',
			title : '<%=WebManager.GetLabel("Upload Files",this).Replace("'","\\'") %>'
		}
	);
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
	