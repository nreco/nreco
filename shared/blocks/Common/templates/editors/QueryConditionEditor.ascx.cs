using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI.WebControls;
using NReco;
using NReco.Web;
using NReco.Web.Site;
using NReco.Web.Site.Controls;
using System.Globalization;
using System.Web.UI;

[ValidationProperty("Value")]
public partial class QueryConditionEditor : System.Web.UI.UserControl, IBindableControl {

	public object DataContext {	get; set; }
	
	public string ConditionsFieldName { get; set; }
	public string ExpressionFieldName { get; set; }
	public string RelexFieldName { get; set; }
	
	public string JsScriptName { get; set; }
	
	public event Func<object,IList<IDictionary<string,object>>> ComposeFieldsData;
	
	public object Value {
		get {
			return null;
		}
	}
	
	public QueryConditionEditor() {
		JsScriptName = "js/jquery.uiquerybuilder-0.1.js";
	}	
	
	protected override void OnLoad(EventArgs e) {
		JsHelper.RegisterJsFile(Page,JsScriptName);
	}
	
	
	public void ExtractValues(System.Collections.Specialized.IOrderedDictionary dictionary) {
		var conditionsJsonStr = conditions.Value;
		var expressionJsonStr = expression.Value;
		
		dictionary[ConditionsFieldName] = conditionsJsonStr;
		dictionary[ExpressionFieldName] = expressionJsonStr;
		
		if (RelexFieldName!=null && !String.IsNullOrEmpty(conditionsJsonStr) && !String.IsNullOrEmpty(expressionJsonStr) ) {
			var expressionData = JsHelper.FromJsonString<IDictionary<string, object>>(expressionJsonStr);
			var exprStr = Convert.ToString(expressionData["expression"]);
			
			if (String.IsNullOrEmpty(exprStr.Trim())) {
				dictionary[RelexFieldName] = "1=1";
			} else {
				var fieldData = JsHelper.FromJsonString<IList<Dictionary<string,object>>>(fieldDescriptors.Value);
				
				var fieldTypeMapping = new Dictionary<string,string>();
				var relexConditionMapping = new Dictionary<string,string>();
				foreach (var fldData in fieldData) {
					fieldTypeMapping[ Convert.ToString(fldData["name"]) ] = Convert.ToString( fldData["dataType"] );
					if (fldData.ContainsKey("relexcondition"))
						relexConditionMapping[ Convert.ToString(fldData["name"]) ] = Convert.ToString( fldData["relexcondition"] );
				}
				dictionary[RelexFieldName] = QueryBuilderHelper.GenerateRelexFromQueryBuilder( JsHelper.FromJsonString<IList<IDictionary<string, object>>>(conditionsJsonStr), exprStr, fieldTypeMapping, relexConditionMapping );
			}
		}
		
	}
	
	protected string GetDateJsPattern() {
		string s = CultureInfo.CurrentCulture.DateTimeFormat.ShortDatePattern.ToLower();
		if (s.IndexOf('m') == s.LastIndexOf('m')) s.Replace("m", "mm");
		if (s.IndexOf('d') == s.LastIndexOf('d')) s.Replace("d", "dd");
		return s.Replace("yyyy","yy");
    }	

	public override void DataBind() {
		OnDataBinding(EventArgs.Empty);
		
		var conditionJsonStr = String.Empty;
		try {
			conditionJsonStr = Convert.ToString(Eval(ConditionsFieldName));
		} catch (Exception ex) { }
		
		conditions.Value = conditionJsonStr;
		
		var expressionStr = String.Empty;
		try {
			expressionStr = Convert.ToString(Eval(ExpressionFieldName));
		} catch (Exception ex) { }
		expression.Value = expressionStr;
		
		fieldDescriptors.Value = GenerateFieldDescriptorsJsonString();
		
		base.DataBind(false);
		
	}
	
	protected string GenerateFieldDescriptorsJsonString() {
		if (ComposeFieldsData==null)
			throw new Exception("ComposeFieldsData is not defined");
		
		var fieldsData = ComposeFieldsData(DataContext);
		
		return JsHelper.ToJsonString(fieldsData);
	}
	
	protected FilterView FindFilter() {
		return this.GetParents<FilterView>().FirstOrDefault();
	}	
	
	protected void HandleLazyFilter(object sender, EventArgs e) {
		var filter = FindFilter();
		if (filter!=null) {
			filter.ApplyFilter();
		}
	}
	

}