<%@ Control Language="c#" AutoEventWireup="false" CodeFile="FlexBoxEditor.ascx.cs" Inherits="FlexBoxEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<span id="<%=ClientID %>">
	<input type="hidden" runat="server" id="selectedValue" value='<%# Value %>'/>
	<input type="hidden" runat="server" id="selectedText" value='<%# GetValueText() %>'/>
	<div id="<%=ClientID %>flexBox"></div>
</span>

<script language="javascript">
jQuery(function(){
	jQuery('#<%=ClientID %>flexBox').flexbox(
		'FlexBoxAjaxHandler.axd?dalc=<%=DalcServiceName %>&relex=<%# HttpUtility.UrlEncode(Relex) %>',
		{ 
			initialValue : jQuery('#<%=selectedText.ClientID %>').val(),
			displayValue : '<%=TextFieldName %>',
			hiddenValue : '<%=ValueFieldName %>',
			resultTemplate : '{<%=TextFieldName %>}',
			showArrow : true,
			maxVisibleRows : 10,
			noResultsText : '<%=WebManager.GetLabel("No matching results",this).Replace("'","\\'") %>',
			paging : {
				style : 'links',
				pageSize : 10,
				summaryTemplate : '{start}-{end} of {total}'
			},
			onSelect : function() {
				var idVal =  this.getAttribute('hiddenValue');
				jQuery('#<%=selectedValue.ClientID %>').val(idVal);
				jQuery('#<%=selectedText.ClientID %>').val(this.value);
			}
		}
	);
	$('#<%=ClientID %>flexBox_input').keyup( function(e) {
		var val = $(this).val();
		if (val=='') {
			jQuery('#<%=selectedValue.ClientID %>').val('');
			jQuery('#<%=selectedText.ClientID %>').val('');
		}
	}).blur( function(e) {
		if ($(this).val()!='')
			$(this).val( jQuery('#<%=selectedText.ClientID %>').val() );
	});
});
</script>
	