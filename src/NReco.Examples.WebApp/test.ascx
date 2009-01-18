<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Web.ActionUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import namespace="System.Data" %>
<%@ Import namespace="System.Data.SqlClient" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<script language="c#" runat="server">
public IProvider<string,string> Prv { get; set; }
public SqlConnection Conn { get; set; }

public void Execute_Save(ActionContext context) {
	aaaButton.Text="BBB";
}

protected override void OnLoad(EventArgs e) {
	base.OnLoad(e);
	//DataBind();
}

</script>
<%=Prv.Provide(null) %>

<asp:Button id="aaaButton" runat="server" text="AAA" CommandName="Save" OnClick="ButtonHandler"/>
<br/><br/>

<asp:ListView ID="listView"
    DataSourceID="accountsDataSource"
    DataKeyNames="id"
    InsertItemPosition="LastItem"

    runat="server">
    <LayoutTemplate>
      <table cellpadding="2" width="640px" border="1" ID="tbl1" runat="server">
        <tr runat="server" style="background-color: #98FB98">
          <th runat="server">ID</th>
          <th runat="server">Login</th>
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
      <tr runat="server">
        <td>
          <asp:Label ID="VendorIDLabel" runat="server" Text='<%# Eval("id") %>' />
          <asp:Button ID="EditButton" runat="server" Text="Edit" CommandName="Edit" />

        </td>
        <td>
          <asp:Label ID="NameLabel" runat="server" Text='<%# Eval("login") %>' /></td>
      </tr>
    </ItemTemplate>
    <InsertItemTemplate>
      <tr class="InsertItem" runat="server">
        <td colspan="2">
          <asp:Button ID="InsertButton" runat="server" CommandName="Insert" Text="Insert" />
          <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" Text="Cancel" />
        </td>
        <td>
          <asp:Label runat="server" ID="NameLabel" AssociatedControlID="login" 
            Text="Name" Font-Bold="true"/><br />
          <asp:TextBox ID="login" runat="server" Text='<%#Bind("login") %>' /><br />
        </td>
      </tr>
    </InsertItemTemplate>
    
</asp:ListView>

<Dalc:DalcDataSource runat="server" id="accountsDataSource" Dalc='<%$ service:db %>' SourceName="accounts"/>