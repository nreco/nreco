<%@ Control Language="c#" AutoEventWireup="false" CodeFile="McDropDownEditor.ascx.cs" Inherits="McDropDownEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<span id="<%=ClientID %>">
	<input type="text" runat="server" id="selectedValue" value='<%# Value %>'/>
	<ul id="<%=ClientID %>tree" class="mcdropdown_menu ui-widget-content" style="display:none">
		<%=RenderHierarchy() %>
	</ul>
	<div style="display:none"><asp:LinkButton id="filter" runat="server" OnClick="HandleSelectedChanged"/></div>
</span>

<script language="javascript">
jQuery(function(){
	jQuery('#<%=selectedValue.ClientID %>').mcDropdown('#<%=ClientID %>tree', 
		{ 
			select : function() {
				<% if (FindFilter()!=null) { %>
				jQuery('.mcdropdown_autocomplete').remove(); // tmp fix
				<%=Page.ClientScript.GetPostBackEventReference(filter,"") %>;
				<% } %>
			}
		});
});
</script>