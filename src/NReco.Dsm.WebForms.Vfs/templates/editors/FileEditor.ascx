<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Dsm.WebForms.EditorUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements interface="System.Web.UI.ITextControl" %>

<script runat="server" language="c#">
public string Text {
	get { return filePath.Value; }
	set { filePath.Value = value; }
}
public bool Overwrite { get; set; }
public string FileSystem { get; set; }
public string Folder { get; set; }

public int ImageMaxWidth { get; set; }
public int ImageMaxHeight { get; set; }
	
public string ImageFormat { get; set; }

public string CssClass { get; set; }

public override object ValidationValue { get { return filePath.Value; } }
</script>

<div id="<%=ClientID %>" class="fileEditor">
	<input type="hidden" id="filePath" runat="server"/>
	<a target="_blank" href="javascript:void(0)" class="fileName"><%=System.IO.Path.GetFileName(filePath.Value) %></a>
	
	<span class="btn btn-default btn-sm btn-file">
		<%=AppContext.GetLabel("Browse", "FileEditor") %>
		<input id="<%=ClientID %>file" name="<%=ClientID %>file" type="file"/>
	</span>

	<NRecoWebForms:JavaScriptHolder runat="server">
		jQuery(function($) {
			var $editor = $('#<%=ClientID %>');
			var uploadUrl = '<%=AppContext.BaseUrlPath %>file/upload';
			var uploadData = {
				filesystem : '<%=FileSystem %>',
				folder : <%=NReco.Dsm.WebForms.JsUtils.ToJsonString(Folder) %>,
				overwrite : <%=Overwrite.ToString().ToLower() %>
			};
			<% if (ImageFormat!=null) { %>
			uploadData['imageformat'] = "<%=ImageFormat %>";
			<% } %>
			<% if (ImageMaxHeight>0) { %>
			uploadData['image_max_height']="<%=ImageMaxHeight %>";
			<% } %>
			<% if (ImageMaxWidth>0) { %>
			uploadData["image_max_width"]="<%=ImageMaxWidth %>";
			<% } %>
			var uploadFormData = [];
			for (var n in uploadData) {
				uploadFormData.push({
					name : n,
					value : uploadData[n]
				});
			}

			var refreshPreview = function() {
				var $filePreview = $editor.find('.fileName');
				var filePath = $('#<%=filePath.ClientID %>').val();
				if (filePath.length>0) {	
					var fileUrl = "<%=AppContext.BaseUrlPath %>file/download?filesystem=<%=HttpUtility.UrlEncode(FileSystem) %>&path="+encodeURIComponent(filePath);
					$filePreview.attr('href',fileUrl).show();
				} else {
					$filePreview.hide();
				}
			};
			refreshPreview();

			$editor.find('input').change(function() {
				var $file = $(this);
				if ($file.val()!='') {
					
					$.ajax( uploadUrl, {
						type : 'POST',
						formData : uploadFormData,
						iframe : true,
						dataType : 'iframe json',
						fileInput : $file
					}).success(function(data) {
						if (data && data.length>0) {
							$editor.find('.fileName').text(data[0].name);
							$('#<%=filePath.ClientID %>').val(data[0].filepath);
							refreshPreview();
						}
						$file.val('');
					});

				}
			});
		});
	</NRecoWebForms:JavaScriptHolder>

</div>