<%@ Page Language="C#" MasterPageFile="~/Site.Master" Inherits="NReco.Web.Site.RoutePage" %>

<script runat="server" language="c#">
protected override void OnInit(EventArgs e) {
	mainPlaceholder.Controls.Add( LoadControl( RouteContext["main"].ToString() ) );
	base.OnInit(e);
}
</script>

<asp:Content ContentPlaceHolderID="main" runat="server">
	<asp:Placeholder runat="server" id="mainPlaceholder"/>
</asp:Content>
