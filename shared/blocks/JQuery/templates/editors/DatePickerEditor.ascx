<%@ Control Language="c#" AutoEventWireup="false" CodeFile="DatePickerEditor.ascx.cs" Inherits="DatePickerEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<span id="<%=ClientID %>">
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
		dateFormat: '<%=GetDateJsPattern() %>',
		firstDay : 1,
		nextText : '<%=WebManager.GetLabel("Next",this) %>',
		prevText : '<%=WebManager.GetLabel("Prev",this) %>',
		dayNamesMin : ['<%=WebManager.GetLabel("Su",this) %>', '<%=WebManager.GetLabel("Mo",this) %>', '<%=WebManager.GetLabel("Tu",this) %>', '<%=WebManager.GetLabel("We",this) %>', '<%=WebManager.GetLabel("Th",this) %>', '<%=WebManager.GetLabel("Fr",this) %>', '<%=WebManager.GetLabel("Sa",this) %>'],
		monthNames : ['<%=WebManager.GetLabel("January",this) %>', '<%=WebManager.GetLabel("February",this) %>', '<%=WebManager.GetLabel("March",this) %>', '<%=WebManager.GetLabel("April",this) %>', '<%=WebManager.GetLabel("May",this) %>', '<%=WebManager.GetLabel("June",this) %>', '<%=WebManager.GetLabel("July",this) %>', '<%=WebManager.GetLabel("August",this) %>', '<%=WebManager.GetLabel("September",this) %>', '<%=WebManager.GetLabel("October",this) %>', '<%=WebManager.GetLabel("November",this) %>', '<%=WebManager.GetLabel("December",this) %>']
	});
});
</script>
</span>