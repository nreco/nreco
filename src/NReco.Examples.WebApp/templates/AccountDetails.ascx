<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Web.ActionUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import namespace="System.Data" %>
<%@ Import namespace="System.Data.SqlClient" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<script language="c#" runat="server">
</script>

<Dalc:DalcDataSource runat="server" id="accountsDataSource" Dalc='<%$ service:db %>' SourceName="accounts"/>

<asp:DetailsView ID="detailsView" runat="server" 
  AutoGenerateRows="True" DataKeyNames="id"
  DataSourceID="accountsDataSource">
</asp:DetailsView>
