<%@ Control Language="c#" AutoEventWireup="false" CodeFile="VfsManager.ascx.cs" Inherits="VfsManager"  TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<link rel="stylesheet" type="text/css" href="css/jqueryFileTree/jqueryFileTree.css" />

<div id="fileTree<%=ClientID %>">
</div>
<div id="fileImagePreview<%=ClientID %>" title="Image Preview" style="display:none">
</div>

<script language="javascript">
jQuery(function(){
    jQuery('#fileTree<%=ClientID %>').fileTree(
		{
			root: '/',
			script: 'jqueryFileTree.aspx?filesystem=<%=FileSystemName %>'
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
				
				dialogDiv.html('<a target="_blank" href="'+fileUrl+'"><img border="0" src="'+fileUrl+'" style="display:none"/></a>');
				dialogDiv.find('img').load( function() {
					if (this.height>0 && this.width>0) {
						var scaleWidth = 1;
						var scaleHeight = 1;
						if (this.width>maxParentWidth)
							scaleWidth = (maxParentWidth/this.width);
						if (this.height>maxParentHeight)
							scaleHeight = (maxParentHeight/this.height);
						var scale = scaleHeight < scaleWidth ? scaleHeight : scaleWidth;
						$(this).height( this.height * scale );
						$(this).width( this.width * scale );
					}
					$(this).show();
					dialogDiv.dialog('open');
				});
				
				dialogDiv.dialog(
					{
						autoOpen : false,
						maxHeight: maxParentHeight,
						maxWidth: maxParentWidth,
						minWidth : 150,
						minHeight: 100,
						width: 'auto',
						height: 'auto',
						buttons: { 
							"Open in New Window": function() { 
								window.open( fileUrl, '_blank');
							}								
						}
					}
				);
			} else if (bgImg.indexOf('code.png')>=0 || bgImg.indexOf('txt.png') || bgImg.indexOf('script.png')) {
				var dialogDiv = preview.html("<div></div>").find('div');
				var maxParentHeight = $(window).height()*0.6;
				var maxParentWidth = $(window).width()*0.6;				
				dialogDiv.html('<iframe border="0" src="'+fileUrl+'" width="'+maxParentWidth+'" height="'+maxParentHeight+'"></iframe>');
				dialogDiv.dialog(
					{
						autoOpen : true,
						maxHeight: maxParentHeight,
						maxWidth: maxParentWidth,
						minWidth : 150,
						minHeight: 100,
						width: 'auto',
						height: 'auto',
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
	