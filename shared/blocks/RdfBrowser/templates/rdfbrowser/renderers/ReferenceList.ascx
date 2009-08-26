<%@ Control Language="c#" AutoEventWireup="false" EnableViewState="false" CodeFile="PropertyValueRenderer.ascx.cs" Inherits="PropertyValueRenderer" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<ul>
<asp:Repeater runat="server" DataSource='<%# Property.References %>'>
	<ItemTemplate>
	<li><a href="rdfbrowser.aspx?resource=<%# HttpUtility.UrlEncode( Eval("Uid.Uri").ToString() ) %>"><%# Eval("Label") %></a></li>
	</ItemTemplate>
</asp:Repeater>
</ul>