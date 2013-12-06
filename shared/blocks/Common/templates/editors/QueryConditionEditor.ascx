<%@ Control Language="c#" AutoEventWireup="false" CodeFile="QueryConditionEditor.ascx.cs" Inherits="QueryConditionEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<div id="<%=ClientID %>" class="ui-state-default queryConditionEditor">
	<input type="hidden" id="expression" runat="server" />
	<input type="hidden" id="conditions" runat="server" />
	<input type="hidden" id="fieldDescriptors" runat="server" />
	
	<div id="<%=ClientID %>QueryConditionBuilder">
		
	</div>
			
	<script type="text/javascript">
		jQuery(function($) {
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
				
				var renderers = [];
				$.each( $.fn.uiQueryBuilder.defaults.renderers, function() { renderers.push(this); } );
				renderers.push(
					{
						name: "datepicker",
						render : function(config, fieldData,defaultValue) {
							var $container = $('<span class="datepickereditor"></span>');
							var $textbox = $('<input type="text"/>');
							$container.append($textbox);
							if (typeof(defaultValue)!='undefined') {
								$textbox.val(defaultValue);
							}
							
							$textbox.datepicker({
								changeYear: true,changeMonth: true,constrainInput : true,showOn : 'both',
								displayClose: true,	inline: false,dateFormat: '<%=GetDateJsPattern() %>',
								buttonText : '',
								firstDay : <%=(int)DayOfWeek.Monday %>,
								nextText : '<%=WebManager.GetLabel("Next",this) %>',
								prevText : '<%=WebManager.GetLabel("Prev",this) %>',
								dayNamesMin : ['<%=WebManager.GetLabel("Su","DatePickerEditor") %>', '<%=WebManager.GetLabel("Mo","DatePickerEditor") %>', '<%=WebManager.GetLabel("Tu","DatePickerEditor") %>', '<%=WebManager.GetLabel("We","DatePickerEditor") %>', '<%=WebManager.GetLabel("Th","DatePickerEditor") %>', '<%=WebManager.GetLabel("Fr","DatePickerEditor") %>', '<%=WebManager.GetLabel("Sa","DatePickerEditor") %>'],
								monthNames : ['<%=WebManager.GetLabel("January","DatePickerEditor") %>', '<%=WebManager.GetLabel("February","DatePickerEditor") %>', '<%=WebManager.GetLabel("March","DatePickerEditor") %>', '<%=WebManager.GetLabel("April","DatePickerEditor") %>', '<%=WebManager.GetLabel("May","DatePickerEditor") %>', '<%=WebManager.GetLabel("June","DatePickerEditor") %>', '<%=WebManager.GetLabel("July","DatePickerEditor") %>', '<%=WebManager.GetLabel("August","DatePickerEditor") %>', '<%=WebManager.GetLabel("September","DatePickerEditor") %>', '<%=WebManager.GetLabel("October","DatePickerEditor") %>', '<%=WebManager.GetLabel("November","DatePickerEditor") %>', '<%=WebManager.GetLabel("December","DatePickerEditor") %>']
							});								
							
							return $container;
						},
						getValue : function($valueContainer) {
							return $valueContainer.find('input').val();
						}
					}
				);
				
				$builder.html('');
				
				//expressionTypes localization
				var expressionTypeLocalization = {
					'all' : '<%=this.GetLabel("Include all of the above") %>',
					'any' : '<%=this.GetLabel("Include any of the above") %>',
					'custom' : '<%=this.GetLabel("Custom condition") %>'
				};
				$.each( $.fn.uiQueryBuilder.defaults.expressionTypes, function() {
					if (expressionTypeLocalization[this.value]) {
						this.text = expressionTypeLocalization[this.value];
					}
				});
				
				$builder.uiQueryBuilder({
					fields : Sys.Serialization.JavaScriptSerializer.deserialize( $('#<%=fieldDescriptors.ClientID %>').val() ),
					renderers : renderers,
					notSelectedFieldText : '<%=this.GetLabel("-- select --") %>'
				});
				
				<% if (FindFilter() != null) { %>
				var $filterLink = $('<span style="margin-left:10px;"><a class="filterSubmit" href="javascript:void(0)"><%=this.GetLabel("Submit") %></a></span><span style="margin-left:10px;"><a class="filterReset" href="javascript:void(0)"><%=this.GetLabel("Reset") %></a></span>');
				$builder.find('.uiQueryBuilderExpressionContainer').append($filterLink);
				$filterLink.find('a.filterSubmit').click(function() {
					doFilter();
					return false;
				});
				$filterLink.find('a.filterReset').click(function() {
					$builder.data('reset')()
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