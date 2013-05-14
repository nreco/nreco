#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2011 Vitaliy Fedorchenko
 * Distributed under the LGPL licence
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#endregion

using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

using NReco;
using NReco.Logging;

public static class QueryBuilderHelper {
	static ILog log = LogManager.GetLogger(typeof(QueryBuilderHelper));

	public static IDictionary<string,object> ComposeNumberTextFieldDescriptor(string name, string caption) {
		var fieldDescriptor = new Dictionary<string,object>();
		fieldDescriptor["name"] = name;
		fieldDescriptor["caption"] = caption;
		fieldDescriptor["dataType"] = "decimal";
		fieldDescriptor["conditions"] = new List<IDictionary<string, object>> {
			new Dictionary<string,object> { {"text", ">"}, {"value", ">"} },
			new Dictionary<string,object> { {"text", "<"}, {"value", "<"} },
			new Dictionary<string,object> { {"text", ">="}, {"value", ">="} },
			new Dictionary<string,object> { {"text", "<="}, {"value", "<="} }
		};
		var rendererData = new Dictionary<string, object>();
		rendererData["name"] = "textbox";
		fieldDescriptor["renderer"] = rendererData;
		return fieldDescriptor;
	}
	
	public static IDictionary<string,object> ComposeTextFieldDescriptor(string name, string caption) {
		var fieldDescriptor = new Dictionary<string,object>();
		fieldDescriptor["name"] = name;
		fieldDescriptor["caption"] = caption;
		fieldDescriptor["dataType"] = "string";
		fieldDescriptor["conditions"] = new List<IDictionary<string, object>> {
			new Dictionary<string,object> { {"text", "like"}, {"value", "like"} },
			new Dictionary<string,object> { {"text", "not like"}, {"value", "!like"} },
			new Dictionary<string,object> { {"text", "="}, {"value", "="} },
			new Dictionary<string,object> { {"text", "<>"}, {"value", "!="} }
		};
		var rendererData = new Dictionary<string, object>();
		rendererData["name"] = "textbox";
		fieldDescriptor["renderer"] = rendererData;
		return fieldDescriptor;
	}

	public static IDictionary<string,object> ComposeDatePickerFieldDescriptor(string name, string caption) {
		var fieldDescriptor = new Dictionary<string,object>();
		fieldDescriptor["name"] = name;
		fieldDescriptor["caption"] = caption;
		fieldDescriptor["dataType"] = "datetime";
		fieldDescriptor["conditions"] = new List<IDictionary<string, object>> {
			new Dictionary<string,object> { {"text", ">"}, {"value", ">"} },
			new Dictionary<string,object> { {"text", "<"}, {"value", "<"} }
		};
		var rendererData = new Dictionary<string, object>();
		rendererData["name"] = "datepicker";
		fieldDescriptor["renderer"] = rendererData;
		return fieldDescriptor;
	}
	
	public static IDictionary<string,object> ComposeDropDownFieldDescriptor(string name, string caption, string lookupPrvName, object lookupContext, string textFld, string valFld) {
		var fieldDescriptor = new Dictionary<string,object>();
		fieldDescriptor["name"] = name;
		fieldDescriptor["caption"] = caption;
		fieldDescriptor["dataType"] = "string";
		fieldDescriptor["conditions"] = new List<IDictionary<string, object>> { 
			new Dictionary<string,object> { {"text", "="}, {"value", "="} },
			new Dictionary<string,object> { {"text", "<>"}, {"value", "!="} }
		};
		
		var rendererData = new Dictionary<string, object>();
		rendererData["name"] = "dropdownlist";
		rendererData["values"] = DataSourceHelper.GetProviderDataSource(lookupPrvName, lookupContext).Cast<object>().Select(r =>
			new Dictionary<string, object> { 
				{"value", DataBinder.Eval(r, valFld) }, 
				{"text", DataBinder.Eval(r, textFld) }
			}).ToArray();
		
		fieldDescriptor["renderer"] = rendererData;
		return fieldDescriptor;
	}
	
	public static string GenerateRelexFromQueryBuilder(IList<IDictionary<string, object>> conditions, string expression, IDictionary<string,string> typeMapping) {
		var relex = expression;
		for (int i=conditions.Count-1; i>=0; i--) {
			var conditionData = conditions[i];
			var fieldName = Convert.ToString(conditionData["field"]);
			var condition = Convert.ToString(conditionData["condition"]);
			
			var escapedValue = Convert.ToString(conditionData["value"]).Replace("\"", "\"\"");
			if (condition.Contains("like")) {
				escapedValue = String.Format("%{0}%", escapedValue);
			}

			var relexValueType = "string";
			if (typeMapping!=null && typeMapping.ContainsKey(fieldName))
				relexValueType = typeMapping[fieldName];

			var relexValue = String.Format("\"{0}\"", escapedValue);
			if (!AssertHelper.IsFuzzyEmpty(relexValueType)) {
				relexValue += ":"+relexValueType;
			}
			
			var condIndexRegex = new Regex(String.Format("(?<![0-9]){0}(?![0-9])", i + 1), RegexOptions.Singleline);

			var singleFieldCondition = String.Format("{0} {1} {2}", conditionData["field"], condition, relexValue);
			relex = condIndexRegex.Replace(relex, singleFieldCondition);
		}
		return relex;
	}
	
	
	
	
	
}