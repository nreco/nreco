<%@ Control Language="c#" AutoEventWireup="false" CodeFile="CheckBoxTreeEditor.ascx.cs" Inherits="CheckBoxTreeEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<style>

.ui-widget-daredevel-checkboxTree {
	padding-left:10px;
	padding-right:10px;
}
.ui-widget-daredevel-checkboxTree li {
    list-style-type: none;
    position: relative;
}

.ui-widget-daredevel-checkboxTree li span {
    cursor: default;
    position: absolute;
    top: 1px;
    left: -16px;
}
#<%=ClientID %> {
	font-weight:normal;
}
#<%=ClientID %> .selectedItems {
}
#<%=ClientID %> .selectedItems span {
	float:left;
	margin:2px;
	margin-left:0px;
	padding:2px;
	white-space:nowrap;
}
#<%=ClientID %> .showTree, #<%=ClientID %> .hideTree {
	padding:2px;
	text-decoration:none;
	text-align:center;	
}
	#<%=ClientID %> .showTree span, #<%=ClientID %> .hideTree span {
		margin-left:10px;
		margin-right:10px;
	}
#<%=ClientID %> ul ul {
	padding-left:40px;
}
</style>

<div id="<%=ClientID %>">
	<input type="hidden" runat="server" id="selectedValues" value="<%# JsHelper.ToJsonString( GetSelectedIds() ) %>"/>
	<div class="selectedItems"><div class="clear"></div></div>
	
	<div style="margin-top:5px;margin-bottom:5px;">
		<a class="showTree ui-widget-content ui-corner-all ui-state-default" href="javascript:void(0)"><span><%=this.GetLabel("select") %></span></a>
		<a class="hideTree ui-widget-content ui-corner-top ui-state-highlight" href="javascript:void(0)" style="display:none;"><span><%=this.GetLabel("hide") %></span></a><br/>
		<div class="treeContainer" style="position:absolute;display:none;z-index:1000000;">
			<ul id="<%=ClientID %>tree" style="max-height:300px;overflow:auto;">
				<%=RenderHierarchy() %>
			</ul>
			<% if (FindFilter()!=null) { %>
			<div class="ui-widget-content applyFilterHolder" style="border-top:0px;">
				<div style="padding:5px;">
				<asp:LinkButton id="applyFilter" CausesValidation="false" runat="server" onclick="HandleFilter" Text='<%$ label: Apply %>'/>
				</div>
			</div>
			<% } %>
		</div>
	</div>

</div>


<script language="javascript">
jQuery(function(){
	var $tree = $('#<%=ClientID %>tree');
	var $selectedValuesInput = $('#<%=selectedValues.ClientID %>');
	var $container = $('#<%=ClientID %>');
	var $treeContainer = $container.find('.treeContainer');
	var $selectedItems = $container.find('.selectedItems');
	
	var $show = $container.find('a.showTree');
	var $hide = $container.find('a.hideTree');
	
	$show.click(function() {
		$treeContainer.show();
		$hide.show();
		$show.hide();
	});
	$hide.click(function() {
		$treeContainer.hide();
		$hide.hide();
		$show.show();		
	});
	
	var selectedIds = $selectedValuesInput.val()!='' ? JSON.parse($selectedValuesInput.val()) : [];
	
	var saveSelected = function() {
		var ids = [];
		var titles = [];
		$selectedItems.find('span').remove();
		$tree.find('input[type="checkbox"]:checked').each(function() {
			ids.push( $(this).val() );
			
			var title = $(this).parent().find('>label:first').text();
			var $selectedItem = $('<span class="ui-widget-content ui-corner-all"/>');
			$selectedItem.text(title);
			$selectedItems.prepend( $selectedItem );
		});
		$selectedValuesInput.val( ids.length>0 ? JSON.stringify(ids) : "" );
	};
	
	$tree.find('input[type="checkbox"]').each(function() {
		$(this).attr('checked', $.inArray( $(this).val(), selectedIds)>=0);
	}).change(function() {
		saveSelected();
	});	
	saveSelected();
	
	$tree.checkboxTree({ 
		collapsable : false,
		onCheck : {
			ancestors : '<%=OnCheckAncestors %>',
			descendants : '<%=OnCheckDescendants %>'
		},
		onUncheck : {
			ancestors : '<%=OnUncheckAncestors %>',
			descendants : '<%=OnUncheckDescendants %>'
		}		
	});
	

	
});
</script>
	