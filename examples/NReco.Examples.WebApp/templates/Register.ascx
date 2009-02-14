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

<asp:CreateUserWizard ID="CreateUserWizard1" Runat="server" 
    ContinueDestinationPageUrl="~/default.aspx">
  <WizardSteps>
    <asp:CreateUserWizardStep Runat="server" 
      Title="Sign Up for Your New Account">
    </asp:CreateUserWizardStep>
    <asp:CompleteWizardStep Runat="server" 
      Title="Complete">
    </asp:CompleteWizardStep>
  </WizardSteps>
</asp:CreateUserWizard>

    
	</ContentTemplate>
</asp:UpdatePanel>