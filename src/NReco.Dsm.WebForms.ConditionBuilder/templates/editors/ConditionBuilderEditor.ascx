<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Dsm.WebForms.EditorUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements interface="System.Web.UI.IBindableControl" %>

<script runat="server" language="c#">
public object DataContext {	get; set; }
public string ConditionsFieldName { get; set; }
public string ExpressionFieldName { get; set; }
public string RelexFieldName { get; set; }
public event Func<object,IList<IDictionary<string,object>>> ComposeFieldsData;
	
public override object ValidationValue { get { return expression.Value; } }

public void ExtractValues(System.Collections.Specialized.IOrderedDictionary dictionary) {
	var conditionsJsonStr = conditions.Value;
	var expressionJsonStr = expression.Value;
	
	if (ConditionsFieldName!=null)
		dictionary[ConditionsFieldName] = conditionsJsonStr;
	if (ExpressionFieldName!=null)
		dictionary[ExpressionFieldName] = expressionJsonStr;
		
	if (RelexFieldName!=null && !String.IsNullOrEmpty(conditionsJsonStr) && !String.IsNullOrEmpty(expressionJsonStr) ) {
		var expressionData = NReco.Dsm.WebForms.JsUtils.FromJsonString<IDictionary<string, object>>(expressionJsonStr);
		var exprStr = Convert.ToString(expressionData["expression"]);
			
		if (String.IsNullOrEmpty(exprStr.Trim())) {
			dictionary[RelexFieldName] = "1=1";
		} else {
			var fieldData = NReco.Dsm.WebForms.JsUtils.FromJsonString<IList<Dictionary<string,object>>>(fieldDescriptors.Value);
				
			var fieldTypeMapping = new Dictionary<string,string>();
			var relexConditionMapping = new Dictionary<string,string>();
			foreach (var fldData in fieldData) {
				fieldTypeMapping[ Convert.ToString(fldData["name"]) ] = Convert.ToString( fldData["dataType"] );
				if (fldData.ContainsKey("relexcondition"))
					relexConditionMapping[ Convert.ToString(fldData["name"]) ] = Convert.ToString( fldData["relexcondition"] );
			}
			dictionary[RelexFieldName] = NReco.Dsm.WebForms.ConditionBuilder.ConditionBuilderHelper.GenerateRelexFromQueryBuilder( NReco.Dsm.WebForms.JsUtils.FromJsonString<IList<IDictionary<string, object>>>(conditionsJsonStr), exprStr, fieldTypeMapping, relexConditionMapping );
		}
	}
		
}

public override void DataBind() {
	OnDataBinding(EventArgs.Empty);
	conditions.Value = String.Empty;
	if (ConditionsFieldName!=null)
		try { conditions.Value = Convert.ToString(Eval(ConditionsFieldName)); } catch {};
	expression.Value = String.Empty;
	if (ExpressionFieldName!=null)
		try { expression.Value =Convert.ToString(Eval(ExpressionFieldName)); } catch {};
		
	fieldDescriptors.Value = NReco.Dsm.WebForms.JsUtils.ToJsonString( ComposeFieldsData(DataContext) );
	base.DataBind(false);	
}


</script>

<div id="<%=ClientID %>" class="conditionBuilderEditor">
	<input type="hidden" id="expression" runat="server" />
	<input type="hidden" id="conditions" runat="server" />
	<input type="hidden" id="fieldDescriptors" runat="server" />
	
	<div id="<%=ClientID %>_conditionBuilder">
		
	</div>
	
	<NRecoWebForms:JavaScriptHolder runat="server">
		jQuery(function($) {
			var $builder = $('#<%=ClientID %>_conditionBuilder');
			
			var saveState = function() {
				$('#<%# conditions.ClientID %>').val( Sys.Serialization.JavaScriptSerializer.serialize( $builder.data('getConditions')() ) );
				$('#<%# expression.ClientID %>').val( Sys.Serialization.JavaScriptSerializer.serialize( $builder.data('getExpression')() ) );
			};
			
			var initBuilder = function() {
				
				$builder.html('');
				
				//expressionTypes localization
				var expressionTypeLocalization = {
					'all' : '<%=AppContext.GetLabel("Include all of the above") %>',
					'any' : '<%=AppContext.GetLabel("Include any of the above") %>',
					'custom' : '<%=AppContext.GetLabel("Custom condition") %>'
				};
				$.each( $.fn.nrecoConditionBuilder.defaults.expressionTypes, function() {
					if (expressionTypeLocalization[this.value]) {
						this.text = expressionTypeLocalization[this.value];
					}
				});
				
				$builder.nrecoConditionBuilder({
					fields : Sys.Serialization.JavaScriptSerializer.deserialize( $('#<%=fieldDescriptors.ClientID %>').val() ),
					notSelectedFieldText : '<%=AppContext.GetLabel("-- select --") %>'
				});
				
				$builder.off("change blur", 'input,select');
				
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
				
				var applyBootstrap = function() {
					$builder.find('input:not(.form-control),select:not(.form-control)').addClass('form-control input-sm');
					$builder.find(this.options.nrecoConditionBuilderHolder).find('.nrecoConditionBuilderConditionRow .rowContainer:not(.form-inline)').addClass('form-inline'); 
				};
				$builder.on("change blur", 'input,select', function() { 
					saveState();
					applyBootstrap();
				} );
				applyBootstrap();
			};
			
			initBuilder();
			
		});
	</NRecoWebForms:JavaScriptHolder>

</div>