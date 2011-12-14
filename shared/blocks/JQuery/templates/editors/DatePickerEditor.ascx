<%@ Control Language="c#" AutoEventWireup="false" CodeFile="DatePickerEditor.ascx.cs" Inherits="DatePickerEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<span id="<%=ClientID %>">
<input type='text' id='dateValue' name='dateValue' runat="server" value='' style='<%# Width>0 ? String.Format("width: {0}px;", Width) : "" %>'/>
<div style="display:none;visibility:hidden">
	<asp:LinkButton id="lazyFilter" runat="server" onclick="HandleLazyFilter"/>		
</div>
<% if (ClearButton) { %>
	<button id="<%=ClientID %>clearButton" type="button">x</button>
<% } %>
<script language="javascript">
jQuery(function(){
	var doFilter = function() {
		<% if (FindFilter() != null && Autofilter) { %>
			<%=Page.ClientScript.GetPostBackEventReference(new PostBackOptions(lazyFilter)) %>;
		<% } %>
	}

	var datePickerElem = jQuery('#<%=dateValue.ClientID %>');
	datePickerElem.datepicker({
		changeYear: <%= YearSelection.ToString().ToLower() %>,
		changeMonth: <%= MonthSelection.ToString().ToLower() %>,
		<%=String.IsNullOrEmpty(YearRange)?"":String.Format("yearRange:'{0}',",YearRange) %>
		constrainInput : true,
		showOn : 'both',
		displayClose: true,
		inline: false,
		dateFormat: '<%=GetDateJsPattern() %>',
		onSelect : function(dateText) {
			doFilter();
		},
		firstDay : <%=(int)FirstDayOfWeek%>,
		nextText : '<%=WebManager.GetLabel("Next",this) %>',
		prevText : '<%=WebManager.GetLabel("Prev",this) %>',
		dayNamesMin : ['<%=WebManager.GetLabel("Su",this) %>', '<%=WebManager.GetLabel("Mo",this) %>', '<%=WebManager.GetLabel("Tu",this) %>', '<%=WebManager.GetLabel("We",this) %>', '<%=WebManager.GetLabel("Th",this) %>', '<%=WebManager.GetLabel("Fr",this) %>', '<%=WebManager.GetLabel("Sa",this) %>'],
		monthNames : ['<%=WebManager.GetLabel("January",this) %>', '<%=WebManager.GetLabel("February",this) %>', '<%=WebManager.GetLabel("March",this) %>', '<%=WebManager.GetLabel("April",this) %>', '<%=WebManager.GetLabel("May",this) %>', '<%=WebManager.GetLabel("June",this) %>', '<%=WebManager.GetLabel("July",this) %>', '<%=WebManager.GetLabel("August",this) %>', '<%=WebManager.GetLabel("September",this) %>', '<%=WebManager.GetLabel("October",this) %>', '<%=WebManager.GetLabel("November",this) %>', '<%=WebManager.GetLabel("December",this) %>']
	});
	jQuery('#<%=ClientID %>clearButton').click(function() { 
		datePickerElem.datepicker( "setDate" , null );
		doFilter();
	});
	datePickerElem.keydown(function(e) {
		if (e.keyCode==13) {
			doFilter();
			return false;
		}
	});
});
</script>
</span>