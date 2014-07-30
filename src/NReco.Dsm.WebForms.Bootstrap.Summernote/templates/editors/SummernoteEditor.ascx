<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Dsm.WebForms.EditorUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements Interface="System.Web.UI.ITextControl" %>

<script runat="server" language="c#">
public override object ValidationValue { get { return Text; } }

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
			var saveContent = function() {
				textarea.val(textarea.code());
			};
			textarea.summernote({
				airMode:false,
				styleTags: ['p', 'blockquote', 'pre', 'h1', 'h2', 'h3'],
				toolbar: [
					['style', ['style']],
					['font', ['bold', 'italic', 'underline', 'superscript', 'subscript', 'strikethrough', 'clear']],
					['color', ['color']],
					['para', ['ul', 'ol', 'paragraph']],
					['insert', ['link', 'picture', 'video', 'hr']],
					['view', ['fullscreen', 'codeview']]
				],
				onChange: function(contents, $editable) {
					saveContent();
				},
				onImageUpload: function(files, editor, $editable) {
					$.each(files, function (idx, file) {
						//editor.insertImage($editable, sDataURL);
					});
				}
			});
			window.<%# ClientID %>_saveContent = saveContent;
		});
	</NRecoWebForms:JavaScriptHolder>

</div>