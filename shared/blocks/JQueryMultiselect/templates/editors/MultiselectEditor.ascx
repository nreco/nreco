<%@ Control Language="c#" AutoEventWireup="false" CodeFile="MultiselectEditor.ascx.cs" Inherits="MultiselectEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<NReco:ListBox id="multiselect"
	class="multiselect"
	style="display:none"
	width="<%# Width>0 ? Width : 500 %>"
	height="<%# Height>0 ? Height : 120 %>"
	runat="server"
	DataTextField="<%# TextFieldName %>"
	DataValueField="<%# ValueFieldName %>"
	SelectionMode="multiple"
	SelectedValues='<%# GetSelectedIds() %>'
	DataSource='<%# GetDataSource() %>'
	PreserveOrder='<%# Sortable %>'/>

<script language="javascript">
jQuery(function(){
	jQuery.ui.multiselect.locale.addAll = '<%=WebManager.GetLabel("Add all",this) %>';
	jQuery.ui.multiselect.locale.removeAll = '<%=WebManager.GetLabel("Remove all",this) %>';
	jQuery.ui.multiselect.locale.itemsCount = '<%=WebManager.GetLabel("items selected",this) %>';
	jQuery('#<%=multiselect.ClientID %>').multiselect(
		{ sortable : <%=Sortable.ToString().ToLower() %>, dividerLocation : 0.5 }
	);
});
</script>
	