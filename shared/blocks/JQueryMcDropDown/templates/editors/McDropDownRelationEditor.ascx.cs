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

public partial class McDropDownRelationEditor : CommonRelationEditor {
	
	public string JsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	
	public string ParentFieldName { get; set; }	
	public bool AllowParentSelect { get; set; }	
	public int Width {get;set;}
	
	public McDropDownRelationEditor() {
		RegisterJs = true;
		JsScriptName = "js/jquery.mcdropdown.min.js";
		Width = 0;
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			JsHelper.RegisterJsFile(Page, JsScriptName);
		}
	}
	
	protected string GetSelectedItemsJson() {
		var selectedIds = GetSelectedIds().Select( id => Convert.ToString(id) );
		var results = new List<object>();
		foreach (var dataEntry in Data) {
			if (selectedIds.Contains( Convert.ToString(DataBinder.Eval(dataEntry,ValueFieldName)) ) )
				results.Add( new Dictionary<string,object>() { {ValueFieldName,DataBinder.Eval(dataEntry,ValueFieldName)} } );
		}
		var json = new JavaScriptSerializer();
		return JsHelper.ToJsonString(results);
	}
	
	protected override IEnumerable GetControlSelectedIds() {
		var json = new JavaScriptSerializer();
		var selectedList = json.DeserializeObject(selectedValues.Value ) as IEnumerable;
		var res = new ArrayList();
		foreach (IDictionary<string,object> i in selectedList)
			res.Add( i[ValueFieldName] );
		return res.ToArray();
	}
	
	IEnumerable _Data;
	protected IEnumerable Data {
		get { return _Data ?? (_Data=DataSourceHelper.GetProviderDataSource(LookupServiceName,LookupDataContext)); }
	}
	
	protected IEnumerable GetLevelData(object parent) {
		foreach (var item in Data)
			if (AssertHelper.AreEquals( DataBinder.Eval(item,ParentFieldName), parent))
				yield return item;
	}
	
	protected void RenderHierarchyLevel(StringBuilder sb, object parent, bool renderList) {
		bool isFirst = true;
		foreach (var item in GetLevelData(parent)) {
			if (isFirst && renderList) {
				sb.Append("<ul class='ui-widget-content'>");
				isFirst = false;
			}
			var uid = DataBinder.Eval(item,ValueFieldName);
			sb.AppendFormat("<li rel='{0}'>{1}", uid,DataBinder.Eval(item,TextFieldName));
			RenderHierarchyLevel( sb, uid, true );
			sb.Append("</li>");
		}
		if (!isFirst && renderList)
			sb.Append("</ul>");
	}
	
	protected string RenderHierarchy() {
		var sb = new StringBuilder();
		RenderHierarchyLevel(sb, DBNull.Value,false);
		return sb.ToString();
	}
	
	
	
}
