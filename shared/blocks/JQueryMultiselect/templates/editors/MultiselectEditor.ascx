<%@ Control Language="c#" AutoEventWireup="false" CodeFile="MultiselectEditor.ascx.cs" Inherits="MultiselectEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<link rel="stylesheet" type="text/css" href="css/ui.multiselect.css" />
<NReco:ListBox id="multiselect"
	class="multiselect"
	width="450"
	height="150"
	DataTextField="Value"
	DataValueField="Key"
	runat="server"
	SelectionMode="multiple"
	SelectedValues='<%# GetSelectedIds() %>'
	DataSource='<%# WebManager.GetService<IProvider<object,IDictionary>>(LookupServiceName).Provide(null) %>'/>

<script language="javascript">
jQuery(function(){
	jQuery('#<%=multiselect.ClientID %>').multiselect(
		{ sortable : false }
	);
});
</script>
	