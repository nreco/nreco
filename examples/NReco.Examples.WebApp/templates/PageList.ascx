<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Web.ActionUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import namespace="System.Data" %>
<%@ Import namespace="System.Data.SqlClient" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<script language="c#" runat="server">
</script>
	
<Dalc:DalcDataSource runat="server" id="pagesDataSource" 
	DataSetMode="true" DataKeyNames="id" AutoIncrementNames="id" Dalc='<%$ service:db %>' SourceName="pages"/>
<NReco:ActionDataSource runat="server" id="actionPagesEntitySource" DataSourceID="pagesDataSource"/>

<asp:UpdatePanel runat="server" UpdateMode="Conditional">
	<ContentTemplate>

<asp:ListView ID="listView"
    DataSourceID="actionPagesEntitySource"
    DataKeyNames="id"
		ItemContainerID="itemPlaceholder"
    runat="server">
<LayoutTemplate>
  <table cellpadding="2" width="80%" border="1" ID="tbl1" runat="server">
    <tr>
      <th>Title</th>
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
    <td>
			<a runat="server" href='<%# this.GetRouteUrl("pageDetails", "title", Eval("title") ) %>'><%# Eval("title") %></a>
		</td>
    <td>
      <asp:LinkButton ID="DeleteButton" runat="server" Text="Delete" CommandName="Delete" />
    </td>
  </tr>
</ItemTemplate>    

</asp:ListView>

	</ContentTemplate>
</asp:UpdatePanel>