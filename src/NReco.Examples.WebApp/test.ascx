<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Web.ActionUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<script language="c#" runat="server">
IProvider<string,string> _Prv;
public IProvider<string,string> Prv {
	get { return _Prv; }
	set { _Prv = value; }
}

public void Execute_Save(ActionContext context) {
	aaaButton.Text="BBB";
}

</script>
<%=Prv.Provide(null) %>

<asp:Button id="aaaButton" runat="server" text="AAA" CommandName="Save" OnClick="ButtonHandler"/>