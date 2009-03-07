<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Web.ActionUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import namespace="System.Data" %>
<%@ Import namespace="System.Data.SqlClient" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<script language="c#" runat="server">
</script>

<Dalc:DalcDataSource runat="server" id="accountsDataSource" 
	DataSetMode="true" DataKeyNames="id" AutoIncrementNames="id" Dalc='<%$ service:db %>' SourceName="accounts"/>
<NReco:ActionDataSource runat="server" id="actionAccountsEntitySource" DataSourceID="accountsDataSource"/>

<asp:UpdatePanel runat="server" UpdateMode="Conditional">
	<ContentTemplate>

<asp:ListView ID="listView"
    DataSourceID="actionAccountsEntitySource"
    DataKeyNames="id"
		ItemContainerID="itemPlaceholder"
    runat="server">
<LayoutTemplate>
  <table cellpadding="2" width="80%" border="1" ID="tbl1" runat="server">
    <tr>
      <th>ID</th>
      <th>Username</th>
      <th>Email</th>
			<th>Registered</th>
			<th>&nbsp;</th>
    </tr>
    <tr runat="server" id="itemPlaceholder" />
  </table>
  <asp:DataPager ID="DataPager1" runat="server">
    <Fields>
      <asp:NumericPagerField />
    </Fields>
  </asp:DataPager>
</LayoutTemplate>
<ItemTemplate>
  <tr>
    <td><%# Eval("id") %></td>
    <td><%# Eval("username") %></td>
    <td><%# Eval("email") %></td>
    <td><%# Eval("creation_date") %></td>
    <td>
			<a href='<%# this.GetRouteUrl("accountDetails", "id", Eval("id") ) %>'>Details</a>
			&nbsp;
			<asp:LinkButton ID="EditButton" runat="server" Text="Change Email" CommandName="Edit" />
			&nbsp;
      <asp:LinkButton ID="DeleteButton" runat="server" Text="Delete" CommandName="Delete" />
    </td>
  </tr>
</ItemTemplate>
    
<EditItemTemplate>
	<tr>
		<td><%# Eval("id") %></td>
		<td>
			<%# Eval("username") %>
		</td>
		<td>
			<asp:TextBox ID="email" runat="server" Text='<%#Bind("email") %>' MaxLength="50" />
		</td>
		<td>
			<%# Eval("creation_date") %>
		</td>
		<td>
			<asp:LinkButton ID="UpdateButton" runat="server" CommandName="Update" Text="Update" />
			&nbsp;
			<asp:LinkButton ID="CancelButton" runat="server" CommandName="Cancel" Text="Cancel" />
		</td>
	</tr>
</EditItemTemplate>
    
</asp:ListView>

	</ContentTemplate>
</asp:UpdatePanel>