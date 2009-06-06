<%@ Control Language="c#" AutoEventWireup="false" CodeFile="VfsManager.ascx.cs" Inherits="VfsManager"  TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<link rel="stylesheet" type="text/css" href="css/jqueryFileTree/jqueryFileTree.css" />

<div id="fileTree<%=ClientID %>">
</div>
<div id="fileImagePreview<%=ClientID %>" title="Image Preview" style="display:none">
</div>

<span id="toolBar" style="display:none; position:absolute; float:left; padding-left: 5px;">
	<div class="ui-state-default ui-corner-all" title=".ui-icon-arrow-4" style="padding: 5px; float:left; margin-right:1px;">
		<span class="ui-icon ui-icon-arrow-4"/>
	</div>	
	<div class="ui-state-default ui-corner-all" title=".ui-icon-pencil" style="padding: 5px; float:left; margin-right:1px;">
		<span class="ui-icon ui-icon-pencil"/>
	</div>	
	
	<div class="ui-state-default ui-corner-all" title=".ui-icon-trash" style="padding: 5px; float:left;">
		<span class="ui-icon ui-icon-trash"/>
	</div>
</span>

<script language="javascript">
jQuery(function(){
    jQuery('#fileTree<%=ClientID %>').fileTree(
		{
			root: '/',
			script: 'jqueryFileTree.aspx?filesystem=<%=FileSystemName %>',
			mouseover : function() {
				$('#toolBar').appendTo( $(this) ).css('display','inline');
			},
			mouseout : function() {
				$('#toolBar').hide();
			}
		}, 
		function(file, elem) {
			var fileUrl = 'jqueryFileTree.aspx?filesystem=<%=FileSystemName %>&file='+escape(file);
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
	);	
});
</script>
	