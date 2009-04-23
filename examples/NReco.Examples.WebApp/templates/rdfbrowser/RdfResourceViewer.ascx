<%@ Control Language="c#" AutoEventWireup="false" CodeFile="RdfResourceViewer.ascx.cs" Inherits="RdfResourceViewer" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

	<h1><%# CurrentResourceUri %></h1>
<asp:Repeater runat="server" DataSource="<%# SingleValues %>">
	<ItemTemplate>
		<%# Eval("Label") %>: <%# Eval("Value") %>
		<br/>
	</ItemTemplate>
</asp:Repeater>