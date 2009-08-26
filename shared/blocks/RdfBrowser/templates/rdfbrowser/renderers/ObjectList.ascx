<%@ Control Language="c#" AutoEventWireup="false" EnableViewState="false" CodeFile="PropertyValueRenderer.ascx.cs" Inherits="PropertyValueRenderer" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<ul>
<asp:Repeater runat="server" DataSource='<%# Property.Values %>'>
	<ItemTemplate>
	<li><%# Container.DataItem %></li>
	</ItemTemplate>
</asp:Repeater>
</ul>