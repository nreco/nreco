<%@ Control Language="c#" AutoEventWireup="false" CodeFile="DatePickerEditor.ascx.cs" Inherits="DatePickerEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<input type='text' id='dateValue' runat="server" value='<%# GetFormattedDate() %>'/>
<div id='datePicker<%=ClientID %>'></div>
<script language="javascript">
jQuery(function(){
	jQuery('#<%=dateValue.ClientID %>').datepicker({
		showYearNavigation: true,
		displayClose: true,
		inline: false
	});
});
</script>,
	