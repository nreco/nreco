<%@ Control Language="c#" AutoEventWireup="false" CodeFile="DatePickerEditor.ascx.cs" Inherits="DatePickerEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<input type='text' id='dateValue' runat="server" value='<%# GetFormattedDate() %>'/>
<script language="javascript">
jQuery(function(){
	jQuery('#<%=dateValue.ClientID %>').datepicker({
		changeYear: <%= YearSelection.ToString().ToLower() %>,
		changeMonth: <%= MonthSelection.ToString().ToLower() %>,
		constrainInput : true,
		showOn : 'both',
		displayClose: true,
		inline: false,
		dateFormat: '<%=GetDateJsPattern() %>'
	});
});
</script>
	