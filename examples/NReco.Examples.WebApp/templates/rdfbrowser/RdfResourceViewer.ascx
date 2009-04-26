<%@ Control Language="c#" AutoEventWireup="false" CodeFile="RdfResourceViewer.ascx.cs" Inherits="RdfResourceViewer" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<style>
	table.rdfResTbl td.centerPanel, table.rdfResTbl td.leftPanel, table.rdfResTbl td.rightPanel {
	vertical-align: top;
	}
</style>

<script language="c#" runat="server">
protected int CenterPanelWidth {
	get {
		int res = 100;
		if (DirectRelations.Count>0)
			res -= 30;
		if (ReverseRelations.Count>0)
			res -= 30;
		return res;
	}
}
</script>

<table border="0" width="100%" height="100%" class="rdfResTbl">
	<tr>
		
		
		<asp:Placeholder runat="server" visible='<%# ReverseRelations.Count>0 %>'>
		<td width="30%" class="rightPanel">
			<div id="rightPanel">
				<asp:Repeater runat="server" DataSource='<%# ReverseRelations.Values %>'>
					<ItemTemplate>
						<h3><a href="#"><%# Eval("Label.Text") %> (<%#Eval("Links.Count")%>)</a></h3>
						<div>
							<a href="rdfbrowser.aspx?resource=<%# HttpUtility.UrlEncode( (string)Eval("Label.Uri") ) %>"><small>(what is <%# Eval("Label.Text") %>)</small></a>						
							<br/>
							<asp:Repeater runat="server" DataSource='<%# Eval("Links") %>'>
								<ItemTemplate>
									<div><a href="rdfbrowser.aspx?resource=<%# HttpUtility.UrlEncode( (string)Eval("Uri") ) %>"><%# Eval("Text") %></a></div>
								</ItemTemplate>
							</asp:Repeater>
						</div>
					</ItemTemplate>
				</asp:Repeater>
			</div>


			<script type="text/javascript">
				$(function() {
					$("#rightPanel").accordion({ fillSpace: false, autoHeight : true, collapsible : true });
				});
			</script>		
		
		</td>
		</asp:Placeholder>
		
		<td width="<%# CenterPanelWidth %>%" class="centerPanel">
			<div class="ui-widget-header ui-corner-top" style="text-align:center; padding: 5px;">
				<%# CurrentResourceLabel %>
			</div>
			<div class="ui-corner-bottom ui-widget-content">
				<table width="100%" class="FormView">
				<asp:Repeater runat="server" DataSource="<%# SingleValues %>">
					<ItemTemplate>
						<tr class="horizontal">
							<th><%# Eval("Label") %>:</th>
							<td><%# Eval("Value") %></td>
						</tr>
					</ItemTemplate>
				</asp:Repeater>
				</table>
				<div runat="server" visible='<%# AboutResourceMessage!=null %>'>
					<%# AboutResourceMessage %>
				</div>
			</div>
		</td>
		
		<asp:Placeholder runat="server" visible='<%# DirectRelations.Count>0 %>'>
		<td width="30%" class="leftPanel">
			<div id="leftPanel">
				<asp:Repeater runat="server" DataSource='<%# DirectRelations.Values %>'>
					<ItemTemplate>
						<h3><a href="#"><%# Eval("Label.Text") %> (<%#Eval("Links.Count")%>)</a></h3>
						<div>
							<a href="rdfbrowser.aspx?resource=<%# HttpUtility.UrlEncode( (string)Eval("Label.Uri") ) %>"><small>(what is <%# Eval("Label.Text") %>)</small></a>
							<br/>
							<asp:Repeater runat="server" DataSource='<%# Eval("Links") %>'>
								<ItemTemplate>
									<div><a href="rdfbrowser.aspx?resource=<%# HttpUtility.UrlEncode( (string)Eval("Uri") ) %>"><%# Eval("Text") %></a></div>
								</ItemTemplate>
							</asp:Repeater>
						</div>
					</ItemTemplate>
				</asp:Repeater>
			</div>

			<script type="text/javascript">
				$(function() {
					$("#leftPanel").accordion({ fillSpace: false, autoHeight : true, collapsible : true });
				});
			</script>			
		
		</td>
		</asp:Placeholder>
		
	</tr>
	<tr>
		<td colspan="3">
		
			<div id="bottomPanel" style="display:none">
				<ul>
					<li><a href="#tabs-1">Long Relation 1</a></li>
					<li><a href="#tabs-2">Long Relation 2</a></li>
					<li><a href="#tabs-3">Long Relation 3</a></li>
				</ul>
				<div id="tabs-1">
					<p>List here.</p>
				</div>
				<div id="tabs-2">
					<p>List here.</p>
				</div>
				<div id="tabs-3">
					<p>List here.</p>
					<p>List here.</p>
				</div>
			</div>


			<script type="text/javascript">
				$(function() {
					$("#bottomPanel").tabs().show();
				});
			</script>
		
		
		</td>
	</tr>
</table>



	
<%# HttpUtility.UrlEncode("#") %>
	