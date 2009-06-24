<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Web.ActionUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import namespace="System.Data" %>
<%@ Import namespace="System.Data.SqlClient" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<script language="c#" runat="server">
protected override void OnLoad(EventArgs e) {
	base.OnLoad(e);
}

</script>

<asp:UpdatePanel runat="server" UpdateMode="Conditional">
	<ContentTemplate>

    <asp:Login id="Login1" runat="server" 
        CssClass="ui-widget-content LoginForm"
		TitleTextStyle-CssClass="ui-widget-header"
        CreateUserText="Create a new user..."
        CreateUserUrl="~/register.aspx" 
        UserNameLabelText="Login:" 
        DestinationPageUrl="~/default.aspx"
				LoginButtonType="Link"
        >
    </asp:Login>
    
	</ContentTemplate>
</asp:UpdatePanel>