<%@ Control Language="c#" AutoEventWireup="false" Inherits="System.Web.UI.UserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<script language="c#" runat="server">
public string FileSystemName { get; set; }
public string FileName { get; set; }
</script>

<span id="<%=ClientID %>" class="file">
	<a target="_blank" href="<%# this.GetFileUrl(FileSystemName,FileName) %>"><%# System.IO.Path.GetFileName(FileName) %></a>
	<asp:Placeholder runat="server" visible="<%# this.IsImageFile(FileName) %>">
		<div class="preview" style="position:absolute;display:none;"><div class="message">Loading...</div><img style="display:none" border="0"/></div>
		
		<script type="text/javascript">
		jQuery( function() {
			$('#<%=ClientID %> a').hover(
				function() {
					var $preview = $('#<%=ClientID %> .preview').show();
					var img = $preview.find('img');
					var $link = $(this);
					if (img.attr('src')!=$link.attr('href'))
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
							if (imgWidth>150 || imgHeight>150) {
								var scale = Math.min( 200/imgWidth, 200/imgHeight );
								jQuery(imgElem).height( imgHeight * scale );
								jQuery(imgElem).width( imgWidth * scale );						
							}
							$(imgElem).show();
							$preview.find('.message').hide();
							} ).attr('src', $link.attr('href') );
				},
				function() {
					$('#<%=ClientID %> .preview').hide();
				}
			);
		});
		</script>
	</asp:Placeholder>
		
</span>
