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
using System.Configuration;
using System.Web.Configuration;

using NReco;
using NReco.Converting;
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public partial class VfsManager : System.Web.UI.UserControl {
	
	
	public string[] JsScriptNames { get; set; }
	public bool RegisterJs { get; set; }
	
	public string FileSystemName { get; set; }
	
	public string RootPath { get; set; }
	
	public string StartDir { get; set; }
	
	public VfsManager() {
		RegisterJs = true;
		JsScriptNames = new[] { "js/jquery.tmpl.min.js", "js/jquery.iframe-transport.js", "js/jquery.fileupload.js", "js/jquery.fileupload-ui.js" };
		RootPath = "/";
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			foreach (var jsName in JsScriptNames)
				JsHelper.RegisterJsFile(Page,jsName);
		}
		if (String.IsNullOrEmpty(StartDir) && this.GetContext()["dir"]!=null)
			StartDir = Convert.ToString(this.GetContext()["dir"]);
	}
	
	
	protected int GetMaxRequestBytesLength() {
		// presume that the section is not defined in the web.config
		HttpRuntimeSection section = ConfigurationManager.GetSection("system.web/httpRuntime") as HttpRuntimeSection;
		if (section != null) return section.MaxRequestLength*1024;
		return 4096*1024; // 4mb by default
	}


}
