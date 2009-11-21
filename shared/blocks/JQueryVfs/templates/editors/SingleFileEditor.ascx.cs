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

using NReco;
using NReco.Converting;
using NReco.Web;
using NReco.Web.Site;
using NReco.Web.Site.Controls;
using NReco.Web.Site.Security;
using NI.Vfs;

[ValidationProperty("Value")]
public partial class SingleFileEditor : System.Web.UI.UserControl {
	
	public string Value {
		get {
			return filePath.Value;
		}
		set {
			filePath.Value = value;
		}
	}
	
	public bool ReadOnly { get; set; }
	
	public bool AllowOverwrite { get; set; }
	
	public bool ClearFormOnUpload { get; set; }
	
	public string FileSystemName { get; set; }
	
	public string BasePath { get; set; }
	
	protected IFileSystem FileSystem {
		get {
			return WebManager.GetService<IFileSystem>(FileSystemName);
		}
	}
	
	public string[] JsScriptNames { get; set; }
	public bool RegisterJs { get; set; }	
	
	public SingleFileEditor() {
		ReadOnly = false;
		AllowOverwrite = false;
		ClearFormOnUpload = true;
		
		RegisterJs = true;
		JsScriptNames = new[] {"js/ajaxfileupload.js"};
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			foreach (var jsName in JsScriptNames)
				JsHelper.RegisterJsFile(Page,jsName);
		}
	}
	
	
}
