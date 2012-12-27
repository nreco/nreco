<%@ Control Language="c#" AutoEventWireup="false" CodeFile="SelectorRelationEditor.ascx.cs" Inherits="SelectorRelationEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<span id="<%=ClientID %>" class="selectorRelationEditor">
	<input type="hidden" runat="server" class="selectedValues" id="selectedValues" value='<%# GetSelectedItemsJson() %>'/>
	<div id="<%=ClientID %>List"></div>
	<div class="clear"></div>
</span>

<script language="javascript">
jQuery(function() {
	var SelectorRelationEditor = function() {
		var selectedValuesElem = jQuery('#<%=selectedValues.ClientID %>');
		
		var selectedItemsList = jQuery('#<%=ClientID %>List');
		
		var getSelectedItems = function() {
			var selectedJson = selectedValuesElem.val();
			return selectedJson!='' ? Sys.Serialization.JavaScriptSerializer.deserialize(selectedJson) : [];
		};
		var setSelectedItems = function(newItems) {
			selectedValuesElem.val( Sys.Serialization.JavaScriptSerializer.serialize(newItems) );
		};
		
		var renderList = function() {
			selectedItemsList.html('');
			jQuery.each(getSelectedItems(), function() {
				selectedItemsList.append('<div class="selectedElement">'+this.Value+'&nbsp;<a class="remove" href="javascript:void(0)" onclick="<%=ClientID %>SelectorRelationEditor.remove(\''+this.Key+'\')">[x]</a></div>');
			});		
		};
		
		this.remove = function(elemId) {
			var selectedItems = getSelectedItems();
			selectedItems = jQuery.map(selectedItems, function(val,i) { return val.Key.toString()==elemId.toString() ? null : val; } );
			setSelectedItems( selectedItems );
			renderList();
		};
		this.add = function(elemId, elemText) {
			var selectedItems = getSelectedItems();
			var isAlreadyExists = false;
			jQuery.each(selectedItems, function() { if (this.Key.toString()==elemId.toString()) isAlreadyExists = true; });
			if (!isAlreadyExists) {
				selectedItems.push({ 'Key' : elemId, 'Value' : elemText });
				setSelectedItems(selectedItems);
				renderList();
			}
		};
		
		renderList();
	};

	window.<%=ClientID %>SelectorRelationEditor = new SelectorRelationEditor();
	window.<%=ClientID %>SelectorRelationEditorAdd = function(id,text) { window.<%=ClientID %>SelectorRelationEditor.add(id,text); };
});

</script>