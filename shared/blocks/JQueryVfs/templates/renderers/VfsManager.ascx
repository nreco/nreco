<%@ Control Language="c#" AutoEventWireup="false" CodeFile="VfsManager.ascx.cs" Inherits="VfsManager"  TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<link rel="stylesheet" type="text/css" href="css/jqueryFileTree/jqueryFileTree.css" />

<div id="fileTree<%=ClientID %>">
</div>
<div id="fileImagePreview<%=ClientID %>" title="Image Preview" style="display:none">
</div>
<div id="fileRename<%=ClientID %>" style="display:none">
	<input type="text"/>
</div>

<span id="fileManagerToolBar<%=ClientID %>" style="display:none; position:absolute; float:left; padding-left: 5px; width: 100px;">
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>move" class="ui-state-default ui-corner-all" title="Move" style="padding: 5px; float:left; margin-right:1px;">
		<span class="ui-icon ui-icon-arrow-4"></span>
	</a>
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>upload" class="ui-state-default ui-corner-all" title="Upload" style="padding: 5px; float:left; margin-right:1px;">
		<span class="ui-icon ui-icon-plusthick"></span>
	</a>

	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>rename" class="ui-state-default ui-corner-all" title="Rename" style="padding: 5px; float:left; margin-right:1px;">
		<span class="ui-icon ui-icon-pencil"></span>
	</a>	
	
	<a href="javascript:void(0)" id="fileManagerToolBar<%=ClientID %>delete" class="ui-state-default ui-corner-all" title="Delete" style="padding: 5px; float:left;">
		<span class="ui-icon ui-icon-trash"></span>
	</a>
</span>

<script language="javascript">
window.FileManager<%=ClientID %> = {
	toolBarFile : null,
	ajaxHandler : 'FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>',
	root: '/',
	expandSpeed : 500,
	collapseSpeed : 500,
	expandEasing : null,
	collapseEasing : null,
	multiFolder : true,
	loadMessage : 'Loading...',
	treeId : 'fileTree<%=ClientID %>',
	
	init : function() {
		// Loading message
		$('#'+this.treeId).html('<ul class="jqueryFileTree start"><li class="wait">' + this.loadMessage + '<li></ul>');
		// Get the initial file list
		this.showTree( $('#'+this.treeId), escape(this.root) );
	},
	
	showTree : function(c, t) {
		c.addClass('wait');
		$(".jqueryFileTree.start").remove();
		$.post(this.ajaxHandler, { dir: t }, function(data) {
			c.find('.start').html('');
			c.removeClass('wait').append(data);
			if( FileManager<%=ClientID %>.root == t ) 
				c.find('UL:hidden').show(); 
			else 
				c.find('UL:hidden').slideDown({ duration: FileManager<%=ClientID %>.expandSpeed, easing: FileManager<%=ClientID %>.expandEasing });
			FileManager<%=ClientID %>.bindTree( c );
		});
	},
				
	switchTreeAction : function(entry) {
		if( entry.parent('LI').hasClass('directory') ) {
			if( entry.parent('LI').hasClass('collapsed') ) {
				// Expand
				if( !this.multiFolder ) {
					entry.parent().parent().find('UL').slideUp({ duration: this.collapseSpeed, easing: this.collapseEasing });
					entry.parent().parent().find('LI.directory').removeClass('expanded').addClass('collapsed');
				}
				entry.parent().find('UL').remove(); // cleanup
				this.showTree( entry.parent(), escape(entry.attr('rel').match( /.*\// )) );
				entry.parent().removeClass('collapsed').addClass('expanded');
			} else if (entry.parent('LI').hasClass('expanded')) {
				// Collapse
				entry.parent().find('UL').slideUp({ duration: this.collapseSpeed, easing: this.collapseEasing });
				entry.parent().removeClass('expanded').addClass('collapsed');
			}
		} else {
			this.viewFile(entry.attr('rel'), entry);
		}
	},
	
	bindTree : function(elem) {
		elem.find('LI A').click( function() {
			FileManager<%=ClientID %>.switchTreeAction($(this));
			return false;
		});
		elem.find('LI A').mouseover( this.mouseover ).mouseout( this.mouseout );
		elem.find('LI A.file').draggable( { 
			handle : '#fileManagerToolBar<%=ClientID %>move',
			revert : true
		} );
		elem.find('LI A.directory').droppable( {
			tolerance : 'pointer',
			accept : '.file',
			activeClass: '.ui-state-highlight',
			hoverClass: '.ui-state-highlight',
			drop: function(event, ui) {
				alert('1');
			}
		} );
	},
	
	toolBarIconIds : {
		'upload' : 'fileManagerToolBar<%=ClientID %>upload',
		'move': 'fileManagerToolBar<%=ClientID %>move',
		'rename' : 'fileManagerToolBar<%=ClientID %>rename',
		'delete' : 'fileManagerToolBar<%=ClientID %>delete'
	},
	
	setupToolbar : function(fileElem) {
		var fileName = fileElem.attr('rel')
		if (this.toolBarFile==fileName)
			return false;
		this.toolBarFile = fileName;
		var icons = (fileName!='' && fileName!='/') ? { 'rename' : true, 'delete' : true } : {};
		if (fileElem.parent('LI').hasClass('directory')) {
			icons.upload = true;
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
	
	renameFile : function(fileElem) {
		var fileName = fileElem.attr('rel')
		var renDialog = $('#fileRename<%=ClientID %>');
		renDialog.find('input').val( fileElem.attr('filename') );
		var ajaxHandler = this.ajaxHandler;
		renDialog.dialog('option', 'buttons', {
				"Rename": function() { 
					fileElem.parent('LI').addClass('wait');
					$.ajax({
						type: "GET", async: true,
						url: ajaxHandler,
						data : {'file':fileName,'action':'rename','newname':renDialog.find('input').val() },
						success : function(res) {
							var fileEntry = fileElem.parent('LI');
							if (fileEntry.find('#fileManagerToolBar<%=ClientID %>').length>0)
								$('#fileManagerToolBar<%=ClientID %>').hide().appendTo( '#fileTree<%=ClientID %>' )
							var fileEntryParent = fileEntry.parent();
							fileEntry.replaceWith(res);
							FileManager<%=ClientID %>.bindTree( fileEntryParent );
						},
						error : function(err) {
							fileElem.parent('LI').removeClass('wait');
						}
					});
					renDialog.dialog("close");
				}								
			});

		renDialog.dialog('open');
	},
	
	deleteFile : function(fileElem) {
		var fileName = fileElem.attr('rel')
		if (!confirm('Are you sure?')) return;
		fileElem.parent('LI').addClass('wait');
		$.ajax({
			type: "GET", async: true,
			url: this.ajaxHandler,
			data : {'file':fileName,'action':'delete'},
			success : function(res) {
				var fileEntry = fileElem.parent('LI');
				if (fileEntry.find('#fileManagerToolBar<%=ClientID %>').length>0)
					$('#fileManagerToolBar<%=ClientID %>').hide().appendTo( '#fileTree<%=ClientID %>' )
				fileEntry.remove();
			},
			error : function(err) {
				fileElem.parent('LI').removeClass('wait');
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
							"Open in New Window": function() { 
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
	// init dialogs
	$('#fileRename<%=ClientID %>').dialog(
		{
			autoOpen : false,
			resizable : false,
			width: 'auto',
			height: 'auto',
			title : 'Rename'
		}
	);
	
	
});
</script>
	