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

public partial class VfsFileRelationEditor : CommonRelationEditor {
	
	public string[] JsScriptNames { get; set; }
	public bool RegisterJs { get; set; }
	public string FileSystemName { get; set; }	
	public string BasePath { get; set; }
	public bool ThumbImage { get; set; }
	public string ThumbImageWidth { get; set; }
	public bool ShowSelect { get; set; }
	
	public string[] AllowedExtensions { get; set; }
	
	public VfsFileRelationEditor() {
		RegisterJs = true;
		JsScriptNames = new[] {"js/json.js", "js/swfobject.js", "js/jquery.uploadify.v2.1.0.min.js" };
		ThumbImage = false;
		ShowSelect = true;
		ThumbImageWidth = "60";
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			foreach (var jsName in JsScriptNames)
				JsHelper.RegisterJsFile(Page,jsName);
		}
	}
	
	protected string GetSelectedItemsJson() {
		var selectedIds = GetSelectedIds();
		if (selectedIds.Length==0)
			return "[]";
		
		var json = new JavaScriptSerializer();
		return json.Serialize(selectedIds);	
	}
	
	protected override IEnumerable GetControlSelectedIds() {
		var json = new JavaScriptSerializer();
		var selectedList = json.DeserializeObject(selectedValues.Value ) as IEnumerable;
		var res = new ArrayList();
		foreach (string fileName in selectedList)
			res.Add( fileName );
		return res.ToArray();
	}
	
}
