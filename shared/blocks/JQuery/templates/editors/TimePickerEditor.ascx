<%@ Control Language="c#" AutoEventWireup="false" CodeFile="TimePickerEditor.ascx.cs" Inherits="TimePickerEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<span id="<%=ClientID %>">
<input type='text' id='timeValue' runat="server"/>
<script language="javascript">
jQuery(function(){
	jQuery('#<%=timeValue.ClientID %>').timeEntry({
		show24Hours: true,
		spinnerImage: 'images/timepicker/spinnerOrange.png'
	});
});
</script>
</span>