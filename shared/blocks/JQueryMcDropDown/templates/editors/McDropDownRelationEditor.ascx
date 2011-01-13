<%@ Control Language="c#" AutoEventWireup="false" CodeFile="McDropDownRelationEditor.ascx.cs" Inherits="McDropDownRelationEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<span id="<%=ClientID %>">
	<input type="hidden" runat="server" class="selectedValues" id="selectedValues" value='<%# GetSelectedItemsJson() %>'/>
	<div id="<%=ClientID %>List"></div>
	
	<span id="<%=ClientID %>_selector">
		<input type="text" runat="server" id="selectedValue" value=''/>
		<ul id="<%=ClientID %>_selector_tree" class="mcdropdown_menu ui-widget-content" style="display:none">
			<%=RenderHierarchy() %>
		</ul>
	</span>

</span>

<script language="javascript">

window.relEditor<%=ClientID %>Remove = function(elemId) {
	var selectedListElem = jQuery('#<%=selectedValues.ClientID %>');
	var selectedList = eval( selectedListElem.val() );
	var prevSelectedList = selectedList;
	var newSelectedList = [];
	for (var idx=0; idx<selectedList.length; idx++)
		if (selectedList[idx]['<%=ValueFieldName %>']!=elemId)
			newSelectedList.push(selectedList[idx]);
	selectedListElem.val( JSON.stringify(newSelectedList) );
	relEditor<%=ClientID %>RenderList();
};

window.relEditor<%=ClientID %>RenderList = function() {
	var cont = jQuery('#<%=ClientID %>List');
	var selectedListElem = jQuery('#<%=selectedValues.ClientID %>');
	cont.html('');
	var selectedList = eval( selectedListElem.val() );
	
	var dropDown = $('#<%=selectedValue.ClientID %>').mcDropdown();
	var listHtml = '';
	for (var elemIdx=0; elemIdx<selectedList.length; elemIdx++) {
		var textPart = selectedList[elemIdx]['<%=TextFieldName %>'];
		var valuePart = selectedList[elemIdx]['<%=ValueFieldName %>'];
		if (textPart==null || textPart=='') {
			dropDown.setValue( valuePart, true );
			textPart = selectedList[elemIdx]['<%=TextFieldName %>'] = dropDown.getValue()[1];
		}
		listHtml = listHtml + '<div class="selectedElement">'+textPart+'&nbsp;<a class="remove" href="javascript:void(0)" onclick="relEditor<%=ClientID %>Remove(\''+valuePart+'\')">[x]</a></div>';
	}
	cont.append(listHtml);
	selectedListElem.val( JSON.stringify(selectedList) );
	dropDown.setValue( null, false );
};

jQuery(function(){
	
	jQuery(function(){
		var mcDropDownElem = jQuery('#<%=selectedValue.ClientID %>').mcDropdown('#<%=ClientID %>_selector_tree', 
			{ 
				allowParentSelect : <%=AllowParentSelect.ToString().ToLower() %>,
				select : function(a) {
					var dropDown = $('#<%=selectedValue.ClientID %>').mcDropdown();
					dropDown.setValue( dropDown.getValue()[0], true );
					var currentValue = dropDown.getValue();
					var idVal =  currentValue[0];
					if (idVal==null || idVal=='') return false;
					
					setTimeout( function() { dropDown.setValue( null, false ); }, 50 );
					
					var textVal = currentValue[1];
					var selectedListElem = jQuery('#<%=selectedValues.ClientID %>');
					var selectedList = eval( selectedListElem.val() );
					for (var selIdx=0; selIdx<selectedList.length; selIdx++) {
						if (selectedList[selIdx]['<%=ValueFieldName %>']==idVal)
							return false;
					}
					
					var prevSelectedList = selectedList;
					selectedList.push( { '<%=ValueFieldName %>' : idVal, '<%=TextFieldName %>' : textVal } );
					selectedListElem.val( JSON.stringify(selectedList) );
					relEditor<%=ClientID %>RenderList();
				}
			});
	});	
	
	relEditor<%=ClientID %>RenderList();
});
</script>