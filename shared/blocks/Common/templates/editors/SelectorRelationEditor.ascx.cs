#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2012 Vitaliy Fedorchenko
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
public partial class SelectorRelationEditor : CommonRelationEditor {
	
	public string JsScriptName { get; set; }
	public string JsonJsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	public object DataContext { get; set; }
	
	public string TextByIdProvider { get; set; }	
	
	public SelectorRelationEditor() {
		RegisterJs = true;
		JsScriptName = "js/jquery.flexbox.js";
		JsonJsScriptName = "js/json.js";
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
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			JsHelper.RegisterJsFile(Page, JsonJsScriptName);
			JsHelper.RegisterJsFile(Page, JsScriptName);
		}
	}
	
	protected string GetSelectedItemsJson() {
		var selectedIds = GetSelectedIds();
		if (selectedIds.Length==0)
			return "[]";
		
		var res = new List<KeyValuePair<object,string>>();
		foreach (var selectedId in res) {
			var text = WebManager.GetService<IProvider<object,string>>( TextByIdProvider ).Provide(selectedId);
			if (text!=null)
				res.Add( new KeyValuePair<object,string>(selectedId, text) );
		}
		
		return JsHelper.ToJsonString(res);		
	}
	
	protected override IEnumerable GetControlSelectedIds() {
		var json = new JavaScriptSerializer();
		var selectedList = JsHelper.FromJsonString<IList<IDictionary>>(selectedValues.Value );
		return selectedList.Select( v => v["Key"] ).ToArray();
	}
	
}
