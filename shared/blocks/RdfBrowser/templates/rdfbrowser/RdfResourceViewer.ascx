<%@ Control Language="c#" AutoEventWireup="false" EnableViewState="false" CodeFile="RdfResourceViewer.ascx.cs" Inherits="RdfResourceViewer" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<%@ Register TagPrefix="R" TagName="PropertyValue" src="./PropertyValue.ascx" %>
<style>
	table.rdfResTbl td.centerPanel, table.rdfResTbl td.leftPanel, table.rdfResTbl td.rightPanel {
	vertical-align: top;
	}
</style>

<script language="c#" runat="server">
protected int CenterWidth {
	get {
		int res = 100;
		if (Right.Count>0)
			res -= 30;
		if (Left.Count>0)
			res -= 30;
		return res;
	}
}
</script>

<table border="0" width="100%" height="100%" class="rdfResTbl">
	<tr>
		<asp:Placeholder runat="server" visible='<%# Left.Count>0 %>'>
		<td width="30%" class="leftPanel">
			<div id="leftPanel">
			
				<asp:Repeater runat="server" DataSource='<%# Left %>'>
					<ItemTemplate>
						<h3><a href="#"><%# Eval("Property.Label") %> (<%#Eval("Values.Count")%>)</a></h3>
						<div>
							<a href="<%=this.GetRouteUrl(BrowserRouteName) %>?resource=<%# HttpUtility.UrlEncode( (string)Eval("Property.Uid.Uri") ) %>"><small>(what is <%# Eval("Property.Label") %>)</small></a>
							<br/>
							<asp:Repeater runat="server" DataSource='<%# Eval("Values") %>'>
								<ItemTemplate>
									<div><%# Container.DataItem %></div>
								</ItemTemplate>
							</asp:Repeater>
						</div>
					</ItemTemplate>
				</asp:Repeater>
			</div>
		</td>
		</asp:Placeholder>
		
		<td width="<%# CenterWidth %>%" class="centerPanel">
			<div id="centerPanelHeader" class="ui-widget-header ui-corner-top" style="text-align:center; padding: 5px; margin-top: 1px;">
				<%# CurrentResource.Label %>
			</div>
			<div id="centerPanelContent" class="ui-corner-bottom ui-widget-content" style="padding:5px;">
				<table width="100%" class="FormView">
				<asp:Repeater runat="server" DataSource="<%# Center %>">
					<ItemTemplate>
						<tr class="horizontal">
							<th><a href="<%=this.GetRouteUrl(BrowserRouteName) %>?resource=<%# HttpUtility.UrlEncode( (string)Eval("Property.Uid.Uri") ) %>"><%# Eval("Property.Label") %></a>:</th>
							<td>
								<%# Eval("Value") %>
							</td>
						</tr>
					</ItemTemplate>
				</asp:Repeater>
				</table>
				<div runat="server" visible='<%# AboutResourceMessage!=null %>'>
					<%# AboutResourceMessage %>
				</div>
			</div>
		</td>
		
		<asp:Placeholder runat="server" visible='<%# Right.Count>0 %>'>
		<td width="30%" class="rightPanel">
			<div id="rightPanel">
			
				<asp:Repeater runat="server" DataSource='<%# Right %>'>
					<ItemTemplate>
						<h3><a href="#"><%# Eval("Property.Label") %> (<%#Eval("References.Count")%>)</a></h3>
						<div>
							<a href="<%=this.GetRouteUrl(BrowserRouteName) %>?resource=<%# HttpUtility.UrlEncode( (string)Eval("Property.Uid.Uri") ) %>"><small>(what is <%# Eval("Property.Label") %>)</small></a>
							<br/>
							<asp:Repeater runat="server" DataSource='<%# Eval("References") %>'>
								<ItemTemplate>
									<div><a href="<%=this.GetRouteUrl(BrowserRouteName) %>?resource=<%# HttpUtility.UrlEncode( (string)Eval("Uid.Uri") ) %>"><%# Eval("Label") %></a></div>
								</ItemTemplate>
							</asp:Repeater>
						</div>
					</ItemTemplate>
				</asp:Repeater>
			</div>
		</td>
		</asp:Placeholder>
		
	</tr>
	
</table>


<script type="text/javascript">
	$(function() {
		$("#leftPanel").accordion({ fillSpace: false, autoHeight : true, collapsible : true });
		$("#rightPanel").accordion({ fillSpace: false, autoHeight : true, collapsible : true });
	});

</script>