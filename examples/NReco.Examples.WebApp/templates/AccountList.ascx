<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Web.ActionUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import namespace="System.Data" %>
<%@ Import namespace="System.Data.SqlClient" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<script language="c#" runat="server">
</script>

<%=Context.User.IsInRole("admin") %>

<Dalc:DalcDataSource runat="server" id="accountsDataSource" Dalc='<%$ service:db %>' SourceName="accounts"/>
<NReco:ActionDataSource runat="server" id="actionAccountsEntitySource" DataSourceID="accountsDataSource"/>

<asp:UpdatePanel runat="server" UpdateMode="Conditional">
	<ContentTemplate>

<asp:ListView ID="listView"
    DataSourceID="actionAccountsEntitySource"
    DataKeyNames="id"
    InsertItemPosition="LastItem"
	ItemContainerID="itemPlaceholder"
    runat="server">
    <LayoutTemplate>
      <table cellpadding="2" width="80%" border="1" ID="tbl1" runat="server">
        <tr runat="server" style="background-color: #98FB98">
          <th runat="server">ID</th>
          <th runat="server">Login</th>
          <th runat="server">Pwd</th>
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
        <td><%# Eval("password") %></td>
        <td>
          <asp:LinkButton ID="EditButton" runat="server" Text="Edit" CommandName="Edit" />
          <asp:LinkButton ID="DeleteButton" runat="server" Text="Delete" CommandName="Delete" />
        </td>
      </tr>
    </ItemTemplate>
    
    <EditItemTemplate>
       <tr>
			<td><%# Eval("id") %></td>
            <td>
              <asp:TextBox ID="LastNameTextBox" runat="server" Text='<%#Bind("username") %>' 
                MaxLength="50" /><br />
            </td>
            <td>
              <asp:TextBox ID="pwd" runat="server" Text='<%#Bind("password") %>' 
                MaxLength="50" /><br />
            </td>
            <td>
              <asp:LinkButton ID="UpdateButton" runat="server" CommandName="Update" Text="Update" />&nbsp;
              <asp:LinkButton ID="CancelButton" runat="server" CommandName="Cancel" Text="Cancel" />
            </td>
       </tr>
    </EditItemTemplate>
    
    <InsertItemTemplate>
    <tr>
		<td>&nbsp;</td>
        <td>
          <asp:TextBox ID="login" runat="server" Text='<%#Bind("username") %>' /><br />
        </td>
            <td>
              <asp:TextBox ID="pwd" runat="server" Text='<%#Bind("password") %>' 
                MaxLength="50" /><br />
            </td>
        
       <td colspan="1">
          <asp:LinkButton ID="InsertButton" runat="server" CommandName="Insert" Text="Insert" />
          <asp:LinkButton ID="CancelButton" runat="server" CommandName="Cancel" Text="Cancel" />
        </td>        
       </tr>
    </InsertItemTemplate>
    
</asp:ListView>

	</ContentTemplate>
</asp:UpdatePanel>