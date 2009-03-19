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

<h1>Pages List</h1>

<asp:ListView ID="listView"
    DataSourceID="actionPagesEntitySource"
    DataKeyNames="id"
		ItemContainerID="itemPlaceholder"
    runat="server">
<LayoutTemplate>
  <table class="listView">
    <tr>
      <th>Title</th>
			<th>Created</th>
			<th>&nbsp;</th>
    </tr>
    <tr runat="server" id="itemPlaceholder" />
  </table>
	<table class="pager"><tr><td>
	  <asp:DataPager ID="DataPager1" runat="server" class="pager">
		<Fields>
		  <asp:NumericPagerField />
		</Fields>
	  </asp:DataPager>
	</td></tr></table>
</LayoutTemplate>
<ItemTemplate>
  <tr>
    <td>
			<a runat="server" href='<%# this.GetRouteUrl("pageDetails", "title", Eval("title") ) %>'><%# Eval("title") %></a>
		</td>
		<td>
			<%# Eval("creation_date") %>
		</td>
    <td>
      <asp:LinkButton ID="DeleteButton" runat="server" Text="Delete" CommandName="Delete" />
    </td>
  </tr>
</ItemTemplate>    

</asp:ListView>

	</ContentTemplate>
</asp:UpdatePanel>