<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Web.ActionUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import namespace="System.Data" %>
<%@ Import namespace="System.Data.SqlClient" %>

<script language="c#" runat="server">
public IProvider<string,string> Prv { get; set; }
public SqlConnection Conn { get; set; }

public void Execute_Save(ActionContext context) {
	aaaButton.Text="BBB";
}

</script>
<%=Prv.Provide(null) %>

<asp:Button id="aaaButton" runat="server" text="AAA" CommandName="Save" OnClick="ButtonHandler"/>