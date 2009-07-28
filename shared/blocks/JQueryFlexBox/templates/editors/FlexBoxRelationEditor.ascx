<%@ Control Language="c#" AutoEventWireup="false" CodeFile="FlexBoxRelationEditor.ascx.cs" Inherits="FlexBoxRelationEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<span id="<%=ClientID %>">
	<input type="hidden" runat="server" id="selectedValues" value='<%# GetSelectedItemsJson() %>'/>
	<div id="<%=ClientID %>List"></div>
	<div id="<%=ClientID %>flexBox"></div>
</span>

<script language="javascript">
window.relEditor<%=ClientID %>Remove = function(elemId) {
	var selectedListElem = jQuery('#<%=selectedValues.ClientID %>');
	var selectedList = eval( selectedListElem.val() );
	var newSelectedList = [];
	for (var idx=0; idx<selectedList.length; idx++)
		if (selectedList[idx]['<%=ValueFieldName %>']!=elemId)
			newSelectedList.push(selectedList[idx]);
	selectedListElem.val( JSON.stringify(newSelectedList) );
	relEditor<%=ClientID %>RenderList();
};

window.relEditor<%=ClientID %>RenderList = function() {
	var cont = jQuery('#<%=ClientID %>List');
	cont.html('');
	var selectedList = eval( jQuery('#<%=selectedValues.ClientID %>').val() );
	for (var elemIdx=0; elemIdx<selectedList.length; elemIdx++)
		cont.append('<div class="selectedElement">'+selectedList[elemIdx]['<%=TextFieldName %>']+'&nbsp;<a class="remove" href="javascript:void(0)" onclick="relEditor<%=ClientID %>Remove(\''+selectedList[elemIdx]['<%=ValueFieldName %>']+'\')">[x]</a></div>');
};

jQuery(function(){
	jQuery('#<%=ClientID %>flexBox').flexbox(
		'FlexBoxAjaxHandler.axd?dalc=<%=DalcServiceName %>&relex=<%# HttpUtility.UrlEncode(Relex) %>',
		{ 
			initialValue : '',
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
				var idVal = this.getAttribute('hiddenValue');
				var textVal = this.value;
				var selectedListElem = jQuery('#<%=selectedValues.ClientID %>');
				var selectedList = eval( selectedListElem.val() );
				selectedList.push( { '<%=ValueFieldName %>' : idVal, '<%=TextFieldName %>' : textVal } );
				selectedListElem.val( JSON.stringify(selectedList) );
				
				relEditor<%=ClientID %>RenderList();
				this.value = ''; /*clear after selection*/
			}
		}
	);
	
	relEditor<%=ClientID %>RenderList();
});
</script>
	