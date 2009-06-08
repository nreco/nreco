<%@ Control Language="c#" AutoEventWireup="false" CodeFile="VfsManager.ascx.cs" Inherits="VfsManager"  TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<link rel="stylesheet" type="text/css" href="css/jqueryFileTree/jqueryFileTree.css" />

<div id="fileTree<%=ClientID %>">
</div>
<div id="fileImagePreview<%=ClientID %>" title="Image Preview" style="display:none">
</div>

<span id="fileManagerToolBar<%=ClientID %>" style="display:none; position:absolute; float:left; padding-left: 5px;">
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
		var icons = { 'rename' : true, 'delete' : true };
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
	
	deleteFile : function() {
		alert(this.toolBarFile);
	},
	
	viewFile : function(file, elem) {
			var fileUrl = 'FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>&file='+escape(file);
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
    // tree
	jQuery('#fileTree<%=ClientID %>').fileTree(
		{
			root: '/',
			script: 'FileTreeAjaxHandler.axd?filesystem=<%=FileSystemName %>',
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
			}
		}, 
		function(file, elem) {
			FileManager<%=ClientID %>.viewFile(file,elem);
		}
	);
	// handlers
	$('#fileManagerToolBar<%=ClientID %>delete').click( function() { FileManager<%=ClientID %>.deleteFile(); return false; } );
});
</script>
	