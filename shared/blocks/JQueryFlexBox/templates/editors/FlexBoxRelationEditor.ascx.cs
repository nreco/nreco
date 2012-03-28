#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
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
using System.Globalization;
using System.Web.Script.Serialization;

using NReco;
using NReco.Converting;
using NReco.Collections;
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;
using NI.Data.RelationalExpressions;

[ValidationProperty("ValidateSelectedValue")]
public partial class FlexBoxRelationEditor : CommonRelationEditor {
	
	public string JsScriptName { get; set; }
	public string JsonJsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	public string DataContextJs { get; set; }
	public object DataContext { get; set; }
	
	public string Relex { get; set; }
	public int Width {get;set;}
	public int? MaxRows {get;set;}
	public int RecordsPerPage { get; set; }
	object _ValidateSelectedValue = null;
	public string MaxRowsReachedMessage { get; set; }
	
	public FlexBoxRelationEditor() {
		RegisterJs = true;
		JsScriptName = "js/jquery.flexbox.js";
		JsonJsScriptName = "js/json.js";
		Width = 0;
		RecordsPerPage = 10;
		MaxRows = null;
		MaxRowsReachedMessage = "Maximum number of items reached";
	}
	
	public object ValidateSelectedValue {
		get {
			var currentSelectedIds = GetControlSelectedIds();
			if (GetControlSelectedIds().Cast<object>().Count() > 0) {
				return JsHelper.ToJsonString(currentSelectedIds);
			} else {
				return null;
			}
		}
	}
	
	protected bool CheckMaxRows {
		get {
			return MaxRows.HasValue && MaxRows.Value > 0;
		}
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			JsHelper.RegisterJsFile(Page, JsonJsScriptName);
			JsHelper.RegisterJsFile(Page, JsScriptName);
		}
	}
	
	protected string GetSelectedItemsJson() {
		var dalc = WebManager.GetService<IDalc>(DalcServiceName);
		var relexParser = new RelExQueryParser(false);
		var exprResolver = WebManager.GetService<NI.Common.Expressions.IExpressionResolver>("defaultExprResolver");
		
		var selectedIds = GetSelectedIds();
		if (selectedIds.Length==0)
			return "[]";
		
		var qContext = new Hashtable();
		qContext["q"] = String.Empty;
		Query q = (Query)relexParser.Parse( Convert.ToString( exprResolver.Evaluate( qContext, Relex ) ) );		
		q.Root = new QueryConditionNode( (QField)ValueFieldName, Conditions.In, new QConst(selectedIds) ); //& q.Root;
		var ds = new DataSet();
		dalc.Load(ds, q);
		
		var results = new IDictionary<string,object>[ds.Tables[q.SourceName].Rows.Count];
		for (int i=0; i<results.Length; i++)
			results[i] = new Dictionary<string,object>( new DataRowDictionaryWrapper( ds.Tables[q.SourceName].Rows[i] ) );
		
		var json = new JavaScriptSerializer();
		return json.Serialize(results);		
	}
	
	protected override IEnumerable GetControlSelectedIds() {
		var json = new JavaScriptSerializer();
		var selectedList = json.DeserializeObject(selectedValues.Value ) as IEnumerable;
		var res = new ArrayList();
		foreach (IDictionary<string,object> i in selectedList)
			res.Add( i[ValueFieldName] );
		return res.ToArray();
	}
	
}
