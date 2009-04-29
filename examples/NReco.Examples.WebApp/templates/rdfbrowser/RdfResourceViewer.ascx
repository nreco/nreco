<%@ Control Language="c#" AutoEventWireup="false" EnableViewState="false" CodeFile="RdfResourceViewer.ascx.cs" Inherits="RdfResourceViewer" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<style>
	table.rdfResTbl td.centerPanel, table.rdfResTbl td.leftPanel, table.rdfResTbl td.rightPanel {
	vertical-align: top;
	}
</style>

<script language="c#" runat="server">
protected int CenterPanelWidth {
	get {
		int res = 100;
		if (RightPanelVisible)
			res -= 30;
		if (LeftPanelVisible)
			res -= 30;
		return res;
	}
}
protected bool LeftPanelVisible {
	get { 
		return ToShortRelations.Count>0 || ToSingleReferences.Count>0;
	}
}	
protected bool RightPanelVisible {
	get {
		return FromShortRelations.Count>0 || FromSingleReferences.Count>0;
	}
}	
</script>

<table border="0" width="100%" height="100%" class="rdfResTbl">
	<tr>
		<asp:Placeholder runat="server" visible='<%# LeftPanelVisible %>'>
		<td width="30%" class="leftPanel">
			<div id="leftPanel">
				<asp:Repeater runat="server" DataSource='<%# ToSingleReferences %>' Visible='<%# ToSingleReferences.Count>0 %>'>
					<HeaderTemplate>
						<h3><a href="#">Referenced From</a></h3>
						<div>
							<table border="0">
					</HeaderTemplate>
					<ItemTemplate>
						<tr>
							<th><a href="rdfbrowser.aspx?resource=<%# HttpUtility.UrlEncode( (string)Eval("Label.Uri") ) %>"><%# Eval("Label.Text") %></a>:</th>
							<td><a href="rdfbrowser.aspx?resource=<%# HttpUtility.UrlEncode( (string)Eval("Link.Uri") ) %>"><%# Eval("Link.Text") %></a></td>
						</tr>
					</ItemTemplate>
					<FooterTemplate>
							</table>
						</div>
					</FooterTemplate>
				</asp:Repeater>
				
				<asp:Repeater runat="server" DataSource='<%# ToShortRelations %>'>
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

		</td>
		</asp:Placeholder>
		
		<td width="<%# CenterPanelWidth %>%" class="centerPanel">
			<div id="centerPanelHeader" class="ui-widget-header ui-corner-top" style="text-align:center; padding: 5px; margin-top: 1px;">
				<%# CurrentResourceLabel %>
			</div>
			<div id="centerPanelContent" class="ui-corner-bottom ui-widget-content" style="padding:5px;">
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
		
		<asp:Placeholder runat="server" visible='<%# RightPanelVisible %>'>
		<td width="30%" class="rightPanel">
			<div id="rightPanel">
				<asp:Repeater runat="server" DataSource='<%# FromSingleReferences %>' Visible='<%# FromSingleReferences.Count>0 %>'>
					<HeaderTemplate>
						<h3><a href="#">References</a></h3>
						<div>
							<table border="0">
					</HeaderTemplate>
					<ItemTemplate>
						<tr>
							<th><a href="rdfbrowser.aspx?resource=<%# HttpUtility.UrlEncode( (string)Eval("Label.Uri") ) %>"><%# Eval("Label.Text") %></a>:</th>
							<td><a href="rdfbrowser.aspx?resource=<%# HttpUtility.UrlEncode( (string)Eval("Link.Uri") ) %>"><%# Eval("Link.Text") %></a></td>
						</tr>
					</ItemTemplate>
					<FooterTemplate>
							</table>
						</div>
					</FooterTemplate>
				</asp:Repeater>
			
				<asp:Repeater runat="server" DataSource='<%# FromShortRelations %>'>
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

		</td>
		</asp:Placeholder>
		
	</tr>
	
	<asp:Placeholder runat="server" visible='<%# LongRelations.Count>0 %>'>
	<tr>
		<td colspan="3">
		
			<div id="bottomPanel" style="display:none">
				<ul>
					<asp:Repeater runat="server" DataSource='<%# LongRelations %>'>
						<ItemTemplate>					
							<li><a href="#tabs<%# Container.ItemIndex %>"><%# Eval("Label.Text") %></a></li>
						</ItemTemplate>
					</asp:Repeater>					
				</ul>
				
				<asp:Repeater runat="server" DataSource='<%# LongRelations %>'>
					<ItemTemplate>					
						<div id="tabs<%# Container.ItemIndex %>">
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

		</td>
	</tr>
	</asp:Placeholder>
</table>


<script type="text/javascript">
	$(function() {
		$("#leftPanel").accordion({ fillSpace: false, autoHeight : true, collapsible : true });
		$("#rightPanel").accordion({ fillSpace: false, autoHeight : true, collapsible : true });
		
		$('#centerPanelContent').height( 
			Math.max( $('#centerPanelContent').height(), $('#centerPanelContent').parent().innerHeight()-$('#centerPanelHeader').outerHeight()-15 )
		);
		$('#leftPanel').accordion('option', 'fillSpace', true);
		$('#rightPanel').accordion('option', 'fillSpace', true);
		$('#rightPanel').resize();
		
		$("#bottomPanel").tabs().show();
	});

</script>