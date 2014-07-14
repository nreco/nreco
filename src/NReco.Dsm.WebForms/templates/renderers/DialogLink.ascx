<%@ Control Language="c#" AutoEventWireup="false" EnableViewState="true" Inherits="System.Web.UI.UserControl"  TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<script language="c#" runat="server">
public string HRef { get; set; }
public string DialogCaption { get; set; }
public string Caption { get; set; }
public int Width { get; set; }
public int Height { get; set; }
public string CallbackCommandName { get; set; }

public string CssClass { 
	get {
		return dialogLink.Attributes["class"];
	}
	set {
		dialogLink.Attributes["class"] = value;
	}
}

public override void DataBind() {
	base.DataBind();
}

protected void DialogLinkCallback_Click(object sender, EventArgs e) {
	var serializedArgs = callbackArgs.Value;

	object actionSender = ControlUtils.GetParents<LayoutUserControl>(this).FirstOrDefault() ?? NamingContainer;
	var args = new ActionEventArgs(CallbackCommandName, new CommandEventArgs(CallbackCommandName, JsUtils.FromJsonString(serializedArgs)));
	AppContext.EventBroker.PublishInTransaction(actionSender, args);
	if (args.ResponseEndRequested)
		Response.End();	
}

</script>
<a id="dialogLink" href="<%# HRef %>" runat="server"><%# AppContext.GetLabel(Caption) %></a>

<asp:Placeholder runat="server" visible='<%# !String.IsNullOrEmpty(CallbackCommandName) %>'>
	<NRecoWebForms:JavaScriptHolder runat="server">
	window.dialogLinkCallback<%=ClientID %> = function(args) {
		$('#<%=callbackArgs.ClientID %>').val( Sys.Serialization.JavaScriptSerializer.serialize(args) );
		<%=Page.ClientScript.GetPostBackEventReference(callbackBtn,"") %>;
	};
	</NRecoWebForms:JavaScriptHolder>
	<span style="display:none;">
		<input type="hidden" runat="server" id="callbackArgs"/>
		<NRecoWebForms:LinkButton id="callbackBtn" CausesValidation="false"
			runat="server" OnClick="DialogLinkCallback_Click"/>
	</span>
</asp:Placeholder>

<NRecoWebForms:JavaScriptHolder runat="server">
$(function() {
	$("#<%=dialogLink.ClientID %>").click(function() {
		var dialogWidth = <%# Width %>;
		var jsCallbackUrlParam = <%# !String.IsNullOrEmpty(CallbackCommandName) ? String.Format("\"jscallback=dialogLinkCallback{0}\"", ClientID ) : "null" %>;
		if (window.NRecoApp && window.NRecoApp.Dialog && window.NRecoApp.Dialog.open) {
			window.NRecoApp.Dialog.open({
				url:this.href,
				title:<%# JsUtils.ToJsonString( AppContext.GetLabel(DialogCaption) ) %>,
				width:dialogWidth,
				extraUrlParams : jsCallbackUrlParam
				<%# Height>0 ? String.Format(",height:{0}",Height) : "" %>
			});
		} else {
			var sizeParams = "width="+dialogWidth+",";
			<%# Height>0 ? String.Format("sizeParams = sizeParams + \"height={0},\";",Height) : "" %>			
			var dialogUrl = this.href;
			if (jsCallbackUrlParam) {
				if (dialogUrl.indexOf('?')<0) dialogUrl+="?";
				dialogUrl += "&"+jsCallbackUrlParam;
			}
			var wnd = window.open( dialogUrl, "NRecoWebFormsDialog", "status=no,toolbar=no,location=no,menubar=no,"+sizeParams);
			wnd.focus();
		}
		return false;
	});
});
</NRecoWebForms:JavaScriptHolder>
