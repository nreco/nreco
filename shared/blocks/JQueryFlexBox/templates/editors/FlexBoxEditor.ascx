<%@ Control Language="c#" AutoEventWireup="false" CodeFile="FlexBoxEditor.ascx.cs" Inherits="FlexBoxEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<span id="<%=ClientID %>" class="flexBoxEditor">
	<input type="hidden" runat="server" class="value" id="selectedValue" value='<%# Value %>'/>
	<input type="hidden" runat="server" class="text" id="selectedText" value='<%# GetValueText() %>'/>
	<input type="hidden" runat="server" class="lastDisplayText" id="lastDisplayText"/>
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
			method : 'POST',maxCacheBytes:0,showArrow : true,maxVisibleRows : 0,
			initialValue : jQuery('#<%=selectedText.ClientID %>').val(),
			displayValue : '<%=TextFieldName %>',
			queryDelay : 500,
			hiddenValue : '<%=ValueFieldName %>',
			resultTemplate : '{<%=TextFieldName %>}',
			<% if (Width>0)  { %>width: <%=Width %>,<% } %>
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
				$('#<%=lastDisplayText.ClientID%>').val(this.value);
				triggerChange();
				<% if (AutoPostBack) { %>
					doPostback();
				<% } %>
			},
			<% if (AddEnabled) { %>
			addNewEntry : {
				onAdd : function(newVal, addCallback) {
					<% if (AddJsFunction==null) { %>
					$.ajax({type: "POST", async: true,
						url: <%=JsHelper.ToJsonString( ComposeAddUrl() ) %>,
						data : { value : newVal },
						success : function(res) {
							var data = JSON.parse(res);
							addCallback(data['<%=ValueFieldName %>'], data['<%=TextFieldName %>']);
						}
					});
					<% } else { %>
						<%=AddJsFunction %>(newVal, addCallback);
					<% } %>
					return true;
				},
				cssClass : "addNewEntry",
				entryTextTemplate : <%=JsHelper.ToJsonString(this.GetLabel("Create \"{q}\"...") ) %>
			},
			<% } %>
			onComposeParams : function(params) {
				var p = <%#DataContextJs ?? "{}" %>;
				p = jQuery.extend( p, <%# JsHelper.ToJsonString(DataContext) %>);
				var legacyContext = p.context;
				delete p.context;
				var newContext = p;
				var result = {"context_json" : JSON.stringify(newContext)};
				if (legacyContext) {
					result["context"] = legacyContext;
				}
				return result;
			}
		}
	);
	var onInputChange = function(input) {
		var val = jQuery(input).val();
		$('#<%=lastDisplayText.ClientID%>').val(val);
		if (val=='' && jQuery('#<%=selectedValue.ClientID %>').val()!="") {
			jQuery('#<%=selectedValue.ClientID %>').val('');
			jQuery('#<%=selectedText.ClientID %>').val('');
			triggerChange();
			<% if (AutoPostBack) { %>
			doPostback();
			<% } %>			
		}	
	};
	jQuery('#<%=ClientID %>flexBox_input').keyup( function(e) { 
		onInputChange(this); 
	}).change(function() {
		onInputChange(this); 
	}).blur( function(e) {
		$('#<%=lastDisplayText.ClientID%>').val(jQuery(this).val());
		if (jQuery(this).val()!='' && (!(jQuery(this).data('active')) || jQuery(this).data('active').toString().toLowerCase() == "false"))
			jQuery(this).val( jQuery('#<%=selectedText.ClientID %>').val() );
	});
});
</script>
	