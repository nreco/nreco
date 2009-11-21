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

using NReco;
using NReco.Converting;
using NReco.Collections;
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;
using NI.Data.RelationalExpressions;

public partial class JsTree : System.Web.UI.UserControl {
	
	public string DalcServiceName { get; set; }
	public bool RegisterJs { get; set; }
	public string[] JsScriptNames { get; set; }

	public string DataProviderName { get; set; }
	public string TextFieldName { get; set; }
	public string ValueFieldName { get; set; }
	public string RootLevelValue { get; set; }
	public string CreateOperationName { get; set; }
	public string DeleteOperationName { get; set; }
	public string RenameOperationName { get; set; }
	
	public JsTree() {
		RegisterJs = true;
		RootLevelValue = null;
		JsScriptNames = new[] { "js/json.js", "js/jsTree/css.js", "js/jsTree/tree_component.min.js" };
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			foreach (var jsName in JsScriptNames)
				JsHelper.RegisterJsFile(Page,jsName);
		}
	}
	
}
