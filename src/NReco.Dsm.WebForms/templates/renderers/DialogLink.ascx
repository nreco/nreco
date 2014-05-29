<%@ Control Language="c#" AutoEventWireup="false" EnableViewState="true" Inherits="System.Web.UI.UserControl"  TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<script language="c#" runat="server">
public string HRef { get; set; }
public string DialogCaption { get; set; }
public string Caption { get; set; }
public int Width { get; set; }
public int Height { get; set; }
public string CallbackAction { get; set; }

public override void DataBind() {
	base.DataBind();
}

protected void DialogLinkCallback_Click(object sender, EventArgs e) {
	var serializedArgs = callbackArgs.Value;

	object actionSender = ControlUtils.GetParents<LayoutUserControl>(this).FirstOrDefault() ?? NamingContainer;
	var args = new ActionEventArgs(CallbackAction, new CommandEventArgs(CallbackAction, JsUtils.FromJsonString(serializedArgs) ) );
	AppContext.EventBroker.PublishInTransaction(actionSender, args);
	if (args.ResponseEndRequested)
		Response.End();	
}

</script>
<a id="dialogLink" href="<%# HRef %>" runat="server"><%# AppContext.GetLabel(Caption) %></a>

<asp:Placeholder runat="server" visible='<%# !String.IsNullOrEmpty(CallbackAction) %>'>
	<script type="text/javascript">
	window.dialogLinkCallback<%=ClientID %> = function(args) {
		iframeDialog.close();
		$('#<%=callbackArgs.ClientID %>').val( Sys.Serialization.JavaScriptSerializer.serialize(args) );
		<%=Page.ClientScript.GetPostBackEventReference(callbackBtn,"") %>;
	};
	</script>
	<span style="display:none;">
		<input type="hidden" runat="server" id="callbackArgs"/>
		<NRecoWebForms:LinkButton id="callbackBtn" CausesValidation="false"
			runat="server" OnClick="DialogLinkCallback_Click"/>
	</span>

</asp:Placeholder>

<script type="text/javascript">
$(function() {
	$("#<%=dialogLink.ClientID %>").click(function() {
		var dialogWidth = <%# Width %>;
		if (window.NRecoWebForms && window.NRecoWebForms.Dialog && window.NRecoWebForms.Dialog.open) {
			window.NRecoWebForms.Dialog.open({
				url:this.href,
				title:<%# JsUtils.ToJsonString( AppContext.GetLabel(DialogCaption) ) %>,
				width:dialogWidth
				<%# Height>0 ? String.Format(",height:{0}",Height) : "" %>
				<%# !String.IsNullOrEmpty(CallbackAction) ? String.Format(",extraUrlParams:\"jscallback=dialogLinkCallback{0}\"", ClientID ) : "" %>
			});
		} else {
			var sizeParams = "width="+dialogWidth+",";
			<%# Height>0 ? String.Format("sizeParams = sizeParams + \"height={0},\";",Height) : "" %>			
			var wnd = window.open( this.href, "NRecoWebFormsDialog", "status=no,toolbar=no,location=no,menubar=no,"+sizeParams);
			wnd.focus();
		}
		return false;
	});
});
</script>
