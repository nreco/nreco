<%@ Control Language="c#" AutoEventWireup="false" CodeFile="FlexBoxEditor.ascx.cs" Inherits="FlexBoxEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<span id="<%=ClientID %>">
	<input type="hidden" runat="server" class="value" id="selectedValue" value='<%# Value %>'/>
	<input type="hidden" runat="server" class="text" id="selectedText" value='<%# GetValueText() %>'/>
	<div id="<%=ClientID %>flexBox"></div>
	<div style="clear:both"></div>
	<% if (AutoPostBack) { %>
	<div style="display:none;">
		<asp:LinkButton id="lazyFilter" runat="server" onclick="HandleLazyFilter"/>		
	</div>
	<% } %>
</span>

<script language="javascript">
jQuery(function(){
	<% if (AutoPostBack) { %>
	var isPostbackStarted = false;
	var doPostback = function() {
		if (isPostbackStarted) return;
		isPostbackStarted = true;
		jQuery('#<%=ClientID %>flexBox_input').attr('disabled',true);
		<%=Page.ClientScript.GetPostBackEventReference(new PostBackOptions(lazyFilter)) %>;
	};
	<% } %>
	var triggerChange = function() {
		jQuery("#<%=ClientID %>").trigger(
			"flexboxValueSelected", [
				jQuery('#<%=selectedValue.ClientID %>').val(), 
				jQuery('#<%=selectedText.ClientID %>').val()
			]);
	};
	
	jQuery('#<%=ClientID %>').data(
		'setFlexboxValue', 
		function(val, text) {
			var selector = 'span#<%=ClientID %>';
			$(selector + " input.value").val(val);
			$(selector + " input.text").val(text);
			$(selector + " div[id$=flexBox]").setValue(text);
			$(selector).trigger(
				'flexboxValueSelected',
				[val, text]
			);
		}
	);
	
	jQuery('#<%=ClientID %>flexBox').flexbox(
		'FlexBoxAjaxHandler.axd?validate=<%=FlexBoxAjaxHandler.GenerateValidationCode(DalcServiceName,Relex) %>&dalc=<%=DalcServiceName %>&relex=<%= HttpUtility.UrlEncode(Relex).Replace("'","\\'") %><%=LocalizationEnabled?String.Format("&label={0}",TextFieldName):"" %>',
		{ 
			method : 'POST', <%#String.IsNullOrEmpty(DataContextJs)?"":"maxCacheBytes:0,"%>
			initialValue : jQuery('#<%=selectedText.ClientID %>').val(),
			displayValue : '<%=TextFieldName %>',
			hiddenValue : '<%=ValueFieldName %>',
			resultTemplate : '{<%=TextFieldName %>}',
			showArrow : true,
			<% if (Width>0)  { %>width: <%=Width %>,<% } %>
			maxVisibleRows : 0,
			noResultsText : '<%=WebManager.GetLabel("No matching results",this).Replace("'","\\'") %>',
			paging : {
				style : 'links',
				pageSize : <%=RecordsPerPage%>,
				summaryTemplate : '{start}-{end} of {total}'
			},
			onSelect : function() {
				var idVal =  this.getAttribute('hiddenValue');
				jQuery('#<%=selectedValue.ClientID %>').val(idVal);
				jQuery('#<%=selectedText.ClientID %>').val(this.value);
				triggerChange();
				<% if (AutoPostBack) { %>
					doPostback();
				<% } %>
			},
			onComposeParams : function(params) {
				var p = <%#DataContextJs ?? "{}" %>;
				p = jQuery.extend( p, <%# JsHelper.ToJsonString(DataContext) %>);
				return p;
			}
		}
	);
	jQuery('#<%=ClientID %>flexBox_input').keyup( function(e) {
		var val = jQuery(this).val();
		if (val=='' && jQuery('#<%=selectedValue.ClientID %>').val()!="") {
			jQuery('#<%=selectedValue.ClientID %>').val('');
			jQuery('#<%=selectedText.ClientID %>').val('');
			triggerChange();
			<% if (AutoPostBack) { %>
			doPostback();
			<% } %>			
		}
	}).blur( function(e) {
		if (jQuery(this).val()!='')
			jQuery(this).val( jQuery('#<%=selectedText.ClientID %>').val() );
	});
});
</script>
	