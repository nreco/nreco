<%@ Control Language="c#" AutoEventWireup="false" CodeFile="McDropDownEditor.ascx.cs" Inherits="McDropDownEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<span id="<%=ClientID %>">
	<input type="hidden" runat="server" id="selectedValue" value='<%# Value %>'/>
	<ul id="<%=ClientID %>tree">
		<!--ToDo render ul list -->
		<li rel="1">AA</li>
	</ul>
</span>

<script language="javascript">
jQuery(function(){
	jQuery('#<%=selectedValue.ClientID %>').mcDropdown('#<%=ClientID %>tree');
});
</script>