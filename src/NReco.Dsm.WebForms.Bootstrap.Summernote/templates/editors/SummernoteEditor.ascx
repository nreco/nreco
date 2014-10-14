<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Dsm.WebForms.EditorUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements Interface="System.Web.UI.ITextControl" %>

<script runat="server" language="c#">
public string UploadFileSystem { get; set; }
public string UploadFolder { get; set; }

public override object ValidationValue { get { return Text; } }

public bool AirMode { get; set; }

public string ToolbarJson { get; set; }

public string Text {
	get {
		return textbox.Text;
	}
	set {
		textbox.Text = value;
	}
}
public string ValidationGroup {
	get { return saveValidator.ValidationGroup; }
	set { saveValidator.ValidationGroup = value; }
}
</script>

<div id="<%=ClientID %>" class="summernoteEditor">
	<asp:TextBox id="textbox" runat="server" TextMode='multiline' ValidateRequestMode="Disabled"/>
	<asp:CustomValidator runat="server" ID="saveValidator" EnableClientScript="true"
		ControlToValidate="textbox" Display="None"
		ValidateEmptyText="true"
		ClientValidationFunction='<%# String.Format("{0}_saveContent", ClientID) %>' />
	<NRecoWebForms:JavaScriptHolder runat="server">
		jQuery(function($) {
			var textarea = $('#<%=textbox.ClientID %>');
			if (textarea.hasClass("summerNoteEditor")) return;
			textarea.addClass("summerNoteEditor");

			var summernoteElem = textarea;
			var saveContent = function() {
				textarea.val(summernoteElem.code());
			};
			
			var customToolbar = <%=ToolbarJson ?? "null" %>;
			var summernoteOptions = {
				styleTags: ['p', 'blockquote', 'pre', 'h1', 'h2', 'h3'],
				onCreateLink: function (sLinkUrl) {
					if (sLinkUrl.indexOf('@') !== -1 && sLinkUrl.indexOf(':') === -1) {
						sLinkUrl =  'mailto:' + sLinkUrl;
					} else if (sLinkUrl.indexOf('://') === -1 && sLinkUrl.indexOf('/') != 0 ) {
						sLinkUrl = 'http://' + sLinkUrl;
					}
					return sLinkUrl;
				},
				<% if (String.IsNullOrEmpty( ToolbarJson )) { %>
				toolbar: [
					['style', ['style']],
					['font', ['bold', 'italic', 'underline', 'superscript', 'subscript', 'strikethrough', 'clear']],
					['color', ['color']],
					['para', ['ul', 'ol', 'paragraph']],
					['insert', ['link', 'picture', 'video', 'hr']],
					['undoredo', ['undo','redo']],
					['view', ['fullscreen', 'codeview']]
				],
				<% } else { %>
					toolbar : customToolbar,
					airPopover : customToolbar,
				<% } %>
				onChange: function(contents, $editable) {
					saveContent();
				}
			};

			<% if (!String.IsNullOrEmpty(UploadFileSystem)) { %>
			summernoteOptions.onImageUpload = function(files, editor, $editable) {
				$.each(files, function (idx, file) {
					var fData = new FormData();
					fData.append("file", file);
					fData.append("filesystem", '<%=UploadFileSystem %>');
					fData.append("folder", <%=NReco.Dsm.WebForms.JsUtils.ToJsonString(UploadFolder) %>);
					fData.append("overwrite", true);
					$.ajax({
						data: fData,
						type: "POST",
						url: '<%=AppContext.BaseUrlPath %>file/upload',
						cache: false,
						contentType: false,
						processData: false,
						success: function(jsonData) {
							var data = JSON.parse(jsonData);
							if (data && data.length>0) {
								var fileUrl = "<%=AppContext.BaseUrlPath %>file/download?filesystem=<%=HttpUtility.UrlEncode(UploadFileSystem) %>&path="+encodeURIComponent(data[0].filepath);
								editor.insertImage($editable, fileUrl);
							}
						}
					});

				});
			};
			<% } %>

			<% if (!System.Threading.Thread.CurrentThread.CurrentUICulture.Name.StartsWith("en-")) { %>
			summernoteOptions.lang = '<%=System.Threading.Thread.CurrentThread.CurrentUICulture.Name %>';
			<% } %>
			
			<% if (AirMode) { %>
			var summernoteElem = $('<div class="panel panel-default" style="padding:5px;min-height:26px;"/>');
			summernoteElem.insertAfter(textarea);
			summernoteElem.html(textarea.val());
			textarea.hide();
			summernoteOptions.airMode = true;
			<% } %>
			summernoteElem.summernote(summernoteOptions);

			window.<%# ClientID %>_saveContent = function() {
				saveContent();
				<% if (AirMode) { %>  
				summernoteElem.destroy(); <%--workaround for popover issue--%>
				summernoteElem.summernote(summernoteOptions);
				<% } %>
			};
		});
	</NRecoWebForms:JavaScriptHolder>

</div>