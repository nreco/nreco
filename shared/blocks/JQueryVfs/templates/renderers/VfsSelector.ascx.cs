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
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public partial class VfsSelector : System.Web.UI.UserControl {
	public string[] AllowedExtensions { get; set; }
	
	public bool RegisterJs { get; set; }
	public string[] JsScriptNames { get; set; }
	
	public string FileSystemName { get; set; }
	public string UploadFolderPath { get; set; }
	public string OpenJsFunction { get; set; }
	
	public bool EnableMultiSelection { get; set; }
	
	public VfsSelector() {
		RegisterJs = true;
		UploadFolderPath = "";
		EnableMultiSelection = false;
		JsScriptNames = new[] {"js/jqueryFileTree.js","js/ajaxfileupload.js"};
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			foreach (var jsName in JsScriptNames)
				JsHelper.RegisterJsFile(Page,jsName);
		}
	}
	
	protected override void OnPreRender(EventArgs e) {
		OnDataBinding(e);
		base.OnPreRender(e);
	}


}
