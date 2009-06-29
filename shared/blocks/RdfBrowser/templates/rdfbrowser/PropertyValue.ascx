<%@ Control Language="c#" AutoEventWireup="false" EnableViewState="false" CodeFile="PropertyValue.ascx.cs" Inherits="PropertyValue" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<asp:Placeholder runat="server" visible='<%# CurrentProperty.HasValue && CurrentProperty.Values.Count==1 %>'>
<%# CurrentProperty.Value %>
</asp:Placeholder>
<asp:Placeholder runat="server" visible='<%# CurrentProperty.HasValue && CurrentProperty.Values.Count>1 %>'>
	<ul>
	<asp:Repeater runat="server" DataSource='<%# CurrentProperty.Values %>'>
		<ItemTemplate>
		<li><%# Container.DataItem %></li>
		</ItemTemplate>
	</asp:Repeater>
	</ul>
</asp:Placeholder>
<asp:Placeholder runat="server" visible='<%# CurrentProperty.HasReference && CurrentProperty.References.Count==1 %>'>
<a href="rdfbrowser.aspx?resource=<%# HttpUtility.UrlEncode( CurrentProperty.Reference.Uid.Uri ) %>"><%# CurrentProperty.Reference.Label %></a>
</asp:Placeholder>
<asp:Placeholder runat="server" visible='<%# CurrentProperty.HasReference && CurrentProperty.References.Count>1 %>'>
	<ul>
	<asp:Repeater runat="server" DataSource='<%# CurrentProperty.References %>'>
		<ItemTemplate>
		<li><a href="rdfbrowser.aspx?resource=<%# HttpUtility.UrlEncode( Eval("Uid.Uri").ToString() ) %>"><%# Eval("Label") %></a></li>
		</ItemTemplate>
	</asp:Repeater>
	</ul>
</asp:Placeholder>

