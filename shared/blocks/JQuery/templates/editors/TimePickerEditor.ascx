	<%@ Control Language="c#" AutoEventWireup="false" CodeFile="TimePickerEditor.ascx.cs" Inherits="TimePickerEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<span id="<%=ClientID %>">
<input type='text' id='timeValue' runat="server"/>
<script language="javascript">
jQuery(function(){
	<%-- this is workaround for js-error that appears in IE + ASP.NET validators --%>
	if (jQuery.browser.msie) {
		document.getElementById('<%=timeValue.ClientID %>').onchange = function(){};
		document.getElementById('<%=timeValue.ClientID %>').onblur = function(){};
	}
	jQuery('#<%=timeValue.ClientID %>').timeEntry({
		show24Hours: true,
		showSeconds: <%=SecondsSelection.ToString().ToLower() %>,
		spinnerImage: 'images/timepicker/spinnerOrange.png',
		beforeSetTime : function(oldTime, newTime, minTime, maxTime) {
			<%-- this is workaround for js-error that appears in IE + ASP.NET validators --%>
			if (jQuery.browser.msie) {
				document.getElementById('<%=timeValue.ClientID %>').onchange = function(){};
				document.getElementById('<%=timeValue.ClientID %>').onblur = function(){};
				jQuery('#<%=timeValue.ClientID %>').focus();
			}
			return newTime;
		}
	});
});
</script>
</span>