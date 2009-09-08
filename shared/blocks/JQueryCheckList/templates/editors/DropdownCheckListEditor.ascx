<%@ Control Language="c#" AutoEventWireup="false" CodeFile="DropdownCheckListEditor.ascx.cs" Inherits="DropdownCheckListEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<NReco:ListBox id="checklist"
	class="checklist"
	style="display:none"
	runat="server"
	DataTextField="<%# TextFieldName %>"
	DataValueField="<%# ValueFieldName %>"
	SelectionMode="multiple"
	SelectedValues='<%# GetSelectedIds() %>'
	DataSource='<%# GetDataSource() %>'/>

<script language="javascript">
jQuery(function(){
	jQuery('#<%=checklist.ClientID %>').dropdownchecklist( { width: 400 });
});
</script>
	