<%@ Control Language="c#" AutoEventWireup="false" CodeFile="RdfResourceViewer.ascx.cs" Inherits="RdfResourceViewer" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<style>
table.rdfResTbl td.centerPanel {
	vertical-align: top;
}
</style>

<table border="0" width="100%" class="rdfResTbl">
	<tr>
		<td width="30%">
			<div id="leftPanel">
				<h3><a href="#">Type Info</a></h3>
				<div>
					<p>
					List here.
					</p>
				</div>
				<h3><a href="#">To Relations</a></h3>
				<div>
					<p>
					List here.
					</p>
				</div>
			</div>


			<script type="text/javascript">
				$(function() {
					$("#leftPanel").accordion();
				});
			</script>			
		
		</td>
		
		<td width="40%" class="centerPanel">
			<h1><%# CurrentResourceLabel %></h1>
			<asp:Repeater runat="server" DataSource="<%# SingleValues %>">
				<ItemTemplate>
					<%# Eval("Label") %>: <%# Eval("Value") %>
					<br/>
				</ItemTemplate>
			</asp:Repeater>		
		</td>
		
		<td width="30%">
			<div id="rightPanel">
				<h3><a href="#">From Relations 1</a></h3>
				<div>
					<p>
					List here.
					</p>
				</div>
				<h3><a href="#">From Relations 3</a></h3>
				<div>
					<p>
					List here.
					</p>
				</div>
			</div>


			<script type="text/javascript">
				$(function() {
					$("#rightPanel").accordion();
				});
			</script>		
		
		</td>
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
	