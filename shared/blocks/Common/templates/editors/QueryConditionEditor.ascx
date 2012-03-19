<%@ Control Language="c#" AutoEventWireup="false" CodeFile="QueryConditionEditor.ascx.cs" Inherits="QueryConditionEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<div id="<%=ClientID %>" class="ui-state-default" style="padding:5px;">
	<input type="hidden" id="expression" runat="server" />
	<input type="hidden" id="conditions" runat="server" />
	
	<div id="<%=ClientID %>QueryConditionBuilder">
		
	</div>
			
	<script type="text/javascript">
		$(function() {
			var fieldData = <%=GenerateFieldDescriptorsJsonString() %>;
			var $builder = $('#<%=ClientID %>QueryConditionBuilder');
			
			var saveState = function() {
				$('#<%# conditions.ClientID %>').val( Sys.Serialization.JavaScriptSerializer.serialize( $builder.data('getConditions')() ) );
				$('#<%# expression.ClientID %>').val( Sys.Serialization.JavaScriptSerializer.serialize( $builder.data('getExpression')() ) );
			};
			
			var doFilter = function() {
				saveState(); 
				<% if (FindFilter() != null) { %>
					<%=Page.ClientScript.GetPostBackEventReference(new PostBackOptions(lazyFilter)) %>;
				<% } %>
			}
			
			var initBuilder = function() {
				
				$builder.html('');
				$builder.uiQueryBuilder({
					fields : fieldData 
				});
				
				<% if (FindFilter() != null) { %>
				var $filterLink = $('<span style="margin-left:10px;"><a class="filterSubmit" href="javascript:void(0)"><%=this.GetLabel("Submit") %></a></span>');
				$builder.find('.uiQueryBuilderExpressionContainer').append($filterLink);
				$filterLink.find('a').click(function() {
					doFilter();
					return false;					
				});
				<% } %>
				
				$builder.find('input,select').die('change').die('blur').die('keydown');
				
				var conditionsJson = $('#<%# conditions.ClientID %>').val();
				if (conditionsJson!="")
					var conditions =  Sys.Serialization.JavaScriptSerializer.deserialize( conditionsJson )
					if (conditions!=null)
						$builder.data('addConditions')(conditions);
				var expressionJson = $('#<%# expression.ClientID %>').val();
				if (expressionJson!="") {
					var exprData = Sys.Serialization.JavaScriptSerializer.deserialize( expressionJson );
					if (exprData!=null)
						$builder.data('setExpression')( exprData.type, exprData.expression);
				}
				
				$builder.find('input,select').live('change', function() { saveState();	} ).live('blur', function() { saveState(); } );
				
				$builder.find('input').live('keydown',function(e) {
					if (e.keyCode==13) {
						doFilter();
						return false;
					}
				});
				
			};
			
			initBuilder();
			
		});
	</script>			
	
<div style="display:none;visibility:hidden;">
	<asp:LinkButton id="lazyFilter" runat="server" onclick="HandleLazyFilter"/>		
</div>	

</div>